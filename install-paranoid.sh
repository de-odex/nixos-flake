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
    sgdisk -Z --set-alignment=34 -n 1:34:2047 --set-alignment=2048 -n 2:0:+1G -n 3:0:-4G -n 4:0:0 -t 1:ef02 -t 2:ef00 -t 3:8300 -t 4:8200 /dev/vda -p
    mkfs.fat -F 32 -n nixos-boot /dev/vda1
    mkfs.ext4 -L nixos-persist /dev/vda2
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

mkdir /mnt/nix
mount /dev/disk/by-label/nixos-persist /mnt/nix
mkdir -p /mnt/nix/persist/{etc/nixos,srv,var/{log,lib}}
mkdir -p /mnt/{boot,etc/nixos,srv,var/{log,lib}}
mount /dev/disk/by-label/nixos-boot /mnt/boot
for i in etc/nixos srv var/{log,lib}; do
  mount --bind /mnt/nix/persist/"$i" /mnt/"$i"
done

files=(etc/ssh/ssh_host_rsa_key etc/ssh/ssh_host_ed25519_key etc/ssh/ssh_host_rsa_key.pub etc/ssh/ssh_host_ed25519_key.pub etc/machine-id)
for i in "${files[@]}"; do
  mkdir -p "$(dirname /mnt/nix/persist/"$i")"
  mkdir -p "$(dirname /mnt/"$i")"
  # touch /mnt/nix/persist/"$i"
  ln -s /mnt/nix/persist/"$i" /mnt/"$i"
done
