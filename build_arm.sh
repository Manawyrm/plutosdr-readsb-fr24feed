#!/bin/bash
pacman-key --init
pacman-key --populate archlinuxarm

pacman -Syu --noconfirm
pacman --noconfirm -S htop screen ntp wget libiio libad9361 base-devel neofetch git

git clone "https://github.com/wiedehopf/readsb" /opt/mnt/opt/readdsb

cd /opt/readdsb
make PLUTOSDR=yes -j$(nproc)

