{self, inputs, ...}: {
  flake.nixosModules.framework16Configuration = {pkgs, lib, ...}: {
    system.stateVersion = "26.05";
    imports = [
      self.nixosModules.general
      self.nixosModules.desktop
      self.nixosModules.gaming
      self.nixosModules.virtualisation
      self.nixosModules.powersave
      self.nixosModules.hardening
      self.nixosModules.secureboot
    ];

    nixpkgs.config.allowUnfree = true;
    nixpkgs.hostPlatform = "x86_64-linux";

    nixpkgs.overlays = [
      inputs.nix-cachyos-kernel.overlays.pinned
    ];

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      extra-substituters = [
        "https://attic.xuyh0120.win/lantian"
        "https://noctalia.cachix.org"
      ];
      extra-trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };

    boot = {
      kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-zen4;

      initrd.luks.devices.cryptroot.device =
        "/dev/disk/by-partlabel/nixos";

      kernelModules = [];

      initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
      ];
    };

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-partlabel/EFI";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    zramSwap.enable = true;

    boot.plymouth.enable = true;

    networking = {
      hostName = "framework16";
      networkmanager = {
        enable = true;
        ethernet.macAddress = "random";

        wifi = {
          powersave = false;
          scanRandMacAddress = true;
          macAddress = "random";
        };
      };
    };

    hardware.cpu.amd.updateMicrocode = true;

    services = {
      udisks2.enable = true;
      fwupd.enable = true;
    };

    services.logind.settings = {
      Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
      };
    };

    services.fprintd.enable = true;

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      optimise.automatic = true;
    };
  };
}
