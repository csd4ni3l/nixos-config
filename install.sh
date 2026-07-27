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
              mountOptions = [ "umask=0077" "noexec" "nodev" "nosuid" ];
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
                mountOptions = [ "relatime" "nosuid" ];
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

sudo mkdir -p /mnt/persist/etc/nixos /mnt/persist/etc/secrets /mnt/persist/var/lib/sbctl /mnt/persist/var/lib/usbguard

echo "Enter password for user csd4ni3l:"
read -rs password1
echo
echo "Confirm password:"
read -rs password2
echo
[[ "$password1" == "$password2" ]]
echo "$password1" | mkpasswd -m yescrypt -s | sudo tee /mnt/persist/etc/secrets/password-hash > /dev/null
unset password1 password2

sudo cp -a . /mnt/persist/etc/nixos

sudo sbctl create-keys -p /mnt/persist/var/lib/sbctl

cat << 'EOF' | sudo tee /mnt/persist/var/lib/usbguard/rules.conf
# First-boot policy: allow hubs, block everything else.
# Replace with a generated policy after first boot:
#   run0 usbguard generate-policy > /var/lib/usbguard/rules.conf
allow with-interface equals { 09:00:00 }
EOF

sudo nixos-install --flake /mnt/persist/etc/nixos#framework16
