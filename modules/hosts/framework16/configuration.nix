{self, inputs, ...}: {
  flake.nixosModules.framework16Configuration = {pkgs, lib, ...}: {
    imports = [
      self.nixosModules.framework16Hardware
      self.nixosModules.general
      self.nixosModules.desktop
      self.nixosModules.gaming
      self.nixosModules.virtualisation
      self.nixosModules.powersave
      self.nixosModules.hardening
    ];

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
        "/dev/disk/by-partlabel/cryptroot";

      loader.grub.enable = true;
      loader.grub.efiSupport = true;
      loader.grub.efiInstallAsRemovable = true;

      kernelModules = [];

      binfmt.emulatedSystems = ["aarch64-linux"];
    };

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
