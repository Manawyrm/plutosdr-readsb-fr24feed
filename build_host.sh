#!/bin/bash

apt update
apt dist-upgrade -y 
DEBIAN_FRONTEND=noninteractive apt -y install git build-essential wget qemu qemu-user-static binfmt-support libarchive-tools qemu-utils sudo

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

