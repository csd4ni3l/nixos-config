{self, inputs, ...}: {
  flake.nixosModules.hostDisko = { pkgs, lib, ... }: {
    imports = [ inputs.disko.nixosModules.disko ];
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
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=25%" "mode=755" ];
    };
    fileSystems."/persist".neededForBoot = true;
    fileSystems."/nix" = {
      device = "/persist/nix";
      fsType = "none";
      options = [ "bind" ];
      neededForBoot = true;
    };
    fileSystems."/home" = {
      device = "/persist/home";
      fsType = "none";
      options = [ "bind" ];
      neededForBoot = true;
    };
  };
}
