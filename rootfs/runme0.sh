#!/bin/sh

cd /media/sdb1

mount -t proc /proc proc/
mount --rbind /sys sys/
mount --rbind /dev dev/

chroot /media/sdb1 /start.sh
