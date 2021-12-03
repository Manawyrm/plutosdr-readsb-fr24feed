#!/bin/sh

cd "$(dirname "$0")"
chroot . /bin/bash -c 'neofetch ; exec /bin/bash'
