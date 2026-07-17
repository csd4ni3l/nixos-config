#!/usr/bin/env bash
set -euo pipefail

DISK="$1"

EFI="${DISK}p1"
ROOT="${DISK}p2"

echo "WARNING: This will erase $DISK"
read -rp "Continue? (yes): " ans
[[ "$ans" == "yes" ]]

wipefs -af "$DISK"
sgdisk --zap-all "$DISK"

parted -s "$DISK" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 1025MiB \
    name 1 EFI \
    set 1 esp on \
    mkpart primary 1025MiB 100% \
    name 2 nixos

partprobe "$DISK"
udevadm settle

mkfs.fat -F32 -n EFI "$EFI"

cryptsetup luksFormat "$ROOT"
cryptsetup open "$ROOT" cryptroot

mkfs.ext4 -L nixos /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount "$EFI" /mnt/boot

mkdir -p /mnt/etc
cp -a . /mnt/etc/nixos

mkdir -p /mnt/var/lib/sbctl
sbctl create-keys -p /mnt/var/lib/sbctl --enroll-config --force

nixos-install --flake /mnt/etc/nixos#framework16
