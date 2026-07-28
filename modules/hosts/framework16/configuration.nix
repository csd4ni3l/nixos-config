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

    nixpkgs.config.allowUnfree = true; # NOTE: needed because of veracrypt
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

    # NOTE: Rules are host-specific, moved from hardening.nix
    services.usbguard.rules = ''
      allow id 1d6b:0002                                               # Linux USB 2.0 root hubs
      allow id 1d6b:0003                                               # Linux USB 3.x root hubs
      allow id 046d:c08b serial "205933F25943"                         # Logitech G502 HERO
      allow id 05e3:0610                                               # Internal Framework USB 2.0 hubs
      allow id 05e3:0625                                               # Internal Framework USB 3.x hub
      allow id 0e8d:e616 serial "000000000"                            # MediaTek Bluetooth
      allow id 32ac:0002 serial "11AD1D009612330C15270B00"             # Framework HDMI Expansion Card
      allow id 27c6:609c serial "UID250B1CD7_XXXX_MOC_B0"              # Goodix fingerprint reader
      allow id 32ac:0018 serial "FRAKDKEN0100000000"                   # Framework Laptop 16 keyboard module (ISO)
      allow id 18a5:0422 serial "WN6L17737000"                         # Portable SSD
      allow id 32ac:0005 serial "071C587D208A2D32"                     # Framework 250 GB Storage Expansion Card
      allow id 0bda:8156 serial "4013000001"                           # Framework 2.5 GbE Ethernet Expansion Card
      allow id 1050:0402                                               # Yubico Security Keys
      allow id 090c:2000 serial "CCYYMMDDHHmmSSRMT223"                 # ADATA 32GB pendrive 1
      allow id 090c:2000 serial "CCYYMMDDHHmmSSKAUUER"                 # ADATA 32GB pendrive 2
      allow id 090c:2000 serial "CCYYMMDDHHmmSS14RYN3"                 # ADATA 32GB pendrive 3
      allow id 0951:1666 serial "E0D55E625B4E18C198B30120"             # Kingston DataTraveler 3.0 128GB
      allow id 125f:dc1a serial "2122607280070066"                     # ADATA UV150 16GB pendrive
      allow id 0951:1666 serial "E0D55E6C711617503942000C"             # Kingston DataTraveler 3.0 64GB
      allow id 058f:6387 serial "CDCD1C5C"                             # Unknown Pendrive 2GB
    '';

    boot.kernelParams = [
      "abmlevel=0" # NOTE: Disable Adaptive Backlight Management which can make display colors look really bad
    ];

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

        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        LockPersonality = true;
        RestrictRealtime = true;
        NoNewPrivileges = true;
        UMask = "0077";
        SystemCallArchitectures = "native";
      };
    };
  };
}
