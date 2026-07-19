#!/usr/bin/env bash
set -euo pipefail

DISK="$1"

echo "WARNING: This will erase $DISK"
read -rp "Continue? (yes): " ans
[[ "$ans" == "yes" ]]

TMPDIR=$(mktemp -d)
cat > "$TMPDIR/disko-config.nix" << 'EOF'
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "1025M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          luks = {
            name = "nixos";
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              extraOpenArgs = [
                "--allow-discards"
                "--perf-no_read_workqueue"
                "--perf-no_write_workqueue"
              ];
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/persist";
                mountOptions = [ "relatime" ];
              };
            };
          };
        };
      };
    };
  };
}
EOF

sudo nix run github:nix-community/disko/latest -- --mode destroy,format,mount "$TMPDIR/disko-config.nix"

sudo mkdir -p /mnt/persist/etc/nixos /mnt/persist/etc/secrets /mnt/persist/var/lib/sbctl

sudo cp -a . /mnt/persist/etc/nixos

sudo sbctl create-keys -p /mnt/persist/var/lib/sbctl

sudo nixos-install --flake /mnt/persist/etc/nixos#framework16
