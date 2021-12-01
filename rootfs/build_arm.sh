#!/bin/bash
pacman-key --init
pacman-key --populate archlinuxarm

pacman -Syu --noconfirm
pacman --noconfirm -S htop screen ntp wget libiio libad9361 base-devel neofetch git

git clone "https://github.com/wiedehopf/readsb" /opt/readsb

cd /opt/readsb
make PLUTOSDR=yes -j$(nproc)

cd /opt
wget "https://repo-feed.flightradar24.com/rpi_binaries/fr24feed_1.0.28-1_armhf.tgz"
tar xfvz fr24feed_1.0.28-1_armhf.tgz
