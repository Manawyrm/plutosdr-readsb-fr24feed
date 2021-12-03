#!/bin/sh

cd "$(dirname "$i")"

FAT_PARTITION=$(echo "$(dirname "$i")" | sed 's/2/1/g')

mount -t proc /proc proc/
mount --rbind /sys sys/
mount --rbind /dev dev/
mount --rbind ${FAT_PARTITION}/ mnt/

chroot . /start.sh
