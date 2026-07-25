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
      self.nixosModules.hostDisko
      self.nixosModules.hostImpermanence
      self.nixosModules.compatibility
    ];

    nixpkgs.config.allowUnfree = true; # needed because of veracrypt
    nixpkgs.hostPlatform = "x86_64-linux";

    nixpkgs.overlays = [
      inputs.nix-cachyos-kernel.overlays.pinned
    ];

    boot = {
      kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-zen4;

      initrd.systemd.enable = true;

      initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
      ];
    };

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 5;
      memoryPercent = 50;
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

    console.keyMap = "hu";

    hardware.cpu.amd.updateMicrocode = true;

    environment.systemPackages = with pkgs; [
      framework-control
      framework-tool
    ];

    systemd.services.framework-control = {
      description = "Framework Control Service";

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [
        framework-tool
        coreutils
        bash
      ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.framework-control}/bin/framework-control";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
