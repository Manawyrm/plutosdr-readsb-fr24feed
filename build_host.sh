#!/bin/bash

apt update
apt dist-upgrade -y 
DEBIAN_FRONTEND=noninteractive apt -y install git build-essential wget qemu qemu-user-static binfmt-support libarchive-tools qemu-utils sudo rsync nano dosfstools pigz fdisk

update-binfmts --enable qemu-arm

mkdir /opt/mnt
wget http://os.archlinuxarm.org/os/ArchLinuxARM-zedboard-latest.tar.gz
bsdtar -xpf ArchLinuxARM-zedboard-latest.tar.gz -C /opt/mnt

rsync -a rootfs/. /opt/mnt

rm /opt/mnt/etc/resolv.conf
echo "nameserver 8.8.8.8" > /opt/mnt/etc/resolv.conf

mount -t proc /proc /opt/mnt/proc/
mount --rbind /sys /opt/mnt/sys/
mount --rbind /dev /opt/mnt/dev/

# pacman's CheckSpace mechanism doesn't work in a chroot which isn't on the root of a filesystem
# Just disable it...
sed -i '/CheckSpace/d' /opt/mnt/etc/pacman.conf

chroot /opt/mnt /build_arm.sh

# create a 5GiB image file
truncate -s 5G /opt/usb.img

# partition it, MBR partition layout, 100MiB FAT32 config, rest as ext4
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /opt/usb.img
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +100M # 100 MB FAT32 config parttion
  t # Change partition type to FAT32
  0c # Hex code for W95 FAT32 (LBA)
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  a # make a partition bootable
  1 # bootable partition is partition 1 -- /dev/sda1
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

# loop mount the image file
losetup -P /dev/loop0 /opt/usb.img

# create both file systems
mkfs.vfat /dev/loop0p1
mkfs.ext4 /dev/loop0p2

# create mount points
mkdir /opt/usb_fat32
mkdir /opt/usb_ext4

# mount the filesystems
mount /dev/loop0p1 /opt/usb_fat32
mount /dev/loop0p2 /opt/usb_ext4

# unmount the bind-mounts inside the chroot
umount -fl /opt/mnt/proc
umount -fl /opt/mnt/sys
umount -fl /opt/mnt/dev

umount /opt/mnt/proc
umount /opt/mnt/sys
umount /opt/mnt/dev

# copy the root fs to the ext4 partition 
rsync -a /opt/mnt/. /opt/usb_ext4/

# unmount the partitions
umount /opt/usb_fat32
umount /opt/usb_ext4

# unmount the loop mount
losetup -D /dev/loop0

# compress the resulting image (using multi-core gzip)
time pigz /opt/usb.img
