#!/bin/sh

cd /media/sdb2

mount -t proc /proc proc/
mount --rbind /sys sys/
mount --rbind /dev dev/

chroot /media/sdb2 /start.sh
