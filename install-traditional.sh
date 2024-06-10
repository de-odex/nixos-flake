#!/usr/bin/env bash
set -x
TEMP=$(getopt -o 'p' --long 'partition' -n 'install.sh' -- "$@")

if [ $? -ne 0 ]; then
  echo 'Terminating...' >&2
  exit 1
fi

# Note the quotes around "$TEMP": they are essential!
eval set -- "$TEMP"
unset TEMP

while true; do
  case "$1" in
  '-p' | '--partition')
    sgdisk -Z -n 1:34:2047 -n 2:0:+1G -n 3:0:-4G -n 4:0:0 -t 1:ef02 -t 2:ef00 -t 3:8300 -t 4:8200 /dev/vda -p
    mkfs.fat -F 32 -n nixos-boot /dev/vda1
    mkfs.ext4 -L nixos-root /dev/vda2
    mkswap -L swap /dev/vda3

    shift
    continue
    ;;
  '--')
    shift
    break
    ;;
  *)
    echo 'Internal error!' >&2
    exit 1
    ;;
  esac
done

swapon /dev/disk/by-label/swap
mount -o remount,size=3G /nix/.rw-store

mount /dev/disk/by-label/nixos-root /mnt
mkdir /mnt/boot
mount /dev/disk/by-label/nixos-boot /mnt/boot
mkdir -p /mnt/etc/age
