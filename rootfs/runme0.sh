#!/bin/sh

cd /media/sdb2

mount -t proc /proc proc/
mount --rbind /sys sys/
mount --rbind /dev dev/
mount --rbind /media/sdb1/ /media/sdb2/mnt/

chroot /media/sdb2 /start.sh
