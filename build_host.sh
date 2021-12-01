#!/bin/bash

apt update
apt dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt -y install git build-essential wget qemu qemu-user-static binfmt-support libarchive-tools qemu-utils sudo rsync nano dosfstools pigz fdisk

update-binfmts --enable qemu-arm

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="${SCRIPT_DIR}/build"

mkdir -p ${BUILD_DIR}
wget http://os.archlinuxarm.org/os/ArchLinuxARM-zedboard-latest.tar.gz
bsdtar -xpf ArchLinuxARM-zedboard-latest.tar.gz -C ${BUILD_DIR}

rsync -a rootfs/. ${BUILD_DIR}

rm ${BUILD_DIR}/etc/resolv.conf
echo "nameserver 8.8.8.8" > ${BUILD_DIR}/etc/resolv.conf

mount -t proc /proc ${BUILD_DIR}/proc/
mount --rbind /sys ${BUILD_DIR}/sys/
mount --rbind /dev ${BUILD_DIR}/dev/

# pacman's CheckSpace mechanism doesn't work in a chroot which isn't on the root of a filesystem
# Just disable it...
sed -i '/CheckSpace/d' ${BUILD_DIR}/etc/pacman.conf

chroot ${BUILD_DIR} /build_arm.sh

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
loopdev=$(losetup -f --show -P /opt/usb.img)

# create both file systems
mkfs.vfat ${loopdev}p1
mkfs.ext4 ${loopdev}p2

# create mount points
mkdir /opt/usb_fat32
mkdir /opt/usb_ext4

# mount the filesystems
mount ${loopdev}p1 /opt/usb_fat32
mount ${loopdev}p2 /opt/usb_ext4

# unmount the bind-mounts inside the chroot
umount -fl ${BUILD_DIR}/proc
umount -fl ${BUILD_DIR}/sys
umount -fl ${BUILD_DIR}/dev

umount ${BUILD_DIR}/proc
umount ${BUILD_DIR}/sys
umount ${BUILD_DIR}/dev

# copy the root fs to the ext4 partition
rsync -a ${BUILD_DIR}/. /opt/usb_ext4/
rsync -a configfs/. /opt/usb_fat32/

# unmount the partitions
umount /opt/usb_fat32
umount /opt/usb_ext4

# unmount the loop mount
losetup -D ${loopdev}

# compress the resulting image (using multi-core gzip)
time pigz /opt/usb.img
