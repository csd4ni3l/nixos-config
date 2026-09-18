{...}: {
  flake.nixosModules.AnotherPublicVMDisko = {inputs, ...}: {
    imports = [inputs.disko.nixosModules.disko];
    disko.devices = {
      disk.main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            EFI = {
              priority = 1;
              name = "EFI";
              label = "EFI";
              start = "1M";
              end = "1025M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077" "noexec" "nodev" "nosuid"];
              };
            };
            root = {
              name = "nixos";
              label = "nixos";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/persist";
                mountOptions = ["relatime" "nosuid" "nodev"];
                postMountHook = "mkdir -p /mnt/persist/nix";
              };
            };
          };
        };
      };
    };

    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=50%" "mode=755" "nosuid" "nodev"];
    };
    fileSystems."/persist".neededForBoot = true;
    fileSystems."/nix".neededForBoot = true;

    disko.devices.nodev."/nix" = {
      fsType = "none";
      device = "/persist/nix";
      mountOptions = ["bind" "exec" "nosuid"];
    };
  };
}
