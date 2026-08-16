{self, ...}: {
  flake.nixosModules.framework16Configuration = {lib, ...}: {
    imports = [
      # general stuff
      self.nixosModules.options
      self.nixosModules.general
      self.nixosModules.users
      self.nixosModules.desktop
      self.nixosModules.gaming
      self.nixosModules.impermanence
      self.nixosModules.podman
      self.nixosModules.virt-manager
      self.nixosModules.powersave
      self.nixosModules.limine
      self.nixosModules.compatibility
      self.nixosModules.bluetooth
      self.nixosModules.networking
      self.nixosModules.zram
      self.nixosModules.tor
      self.nixosModules.sops

      # hardening
      self.nixosModules.HardeningKernel
      self.nixosModules.HardeningMisc
      self.nixosModules.HardeningNoSUID
      self.nixosModules.HardeningServices
      self.nixosModules.HardeningSysCtl
      self.nixosModules.HardeningUSBGuard
      self.nixosModules.HardeningFaillock
      self.nixosModules.HardeningFUSENoSUID
      self.nixosModules.HardeningQEMUNoSUID
      self.nixosModules.HardeningPolkitNoSUID
      self.nixosModules.HardeningRandomMAC
      self.nixosModules.HardeningBluetooth
      self.nixosModules.HardeningPlymouth

      # host-specific/framework stuff
      self.nixosModules.FrameworkControl
      self.nixosModules.Framework16Disko
      self.nixosModules.Framework16Boot
      self.nixosModules.Framework16USBGuard
      self.nixosModules.Framework16Sops

      # nixpak apps
      self.nixosModules.nixpak
      self.nixosModules.Mpv
      self.nixosModules.AnyType
      self.nixosModules.Firefox
      self.nixosModules.AaglGtk
      self.nixosModules.BurpSuite
      self.nixosModules.FedoraMediaWriter
      self.nixosModules.Ghidra
      self.nixosModules.GnomeCalculator
      self.nixosModules.Jrnl
      self.nixosModules.Kdenlive
      self.nixosModules.MissionCenter
      self.nixosModules.MoneroGui
      self.nixosModules.NicotinePlus
      self.nixosModules.Obsidian
      self.nixosModules.ObsStudio
      self.nixosModules.OnlyOffice
      self.nixosModules.OpenCode
      self.nixosModules.OrcaSlicer
      self.nixosModules.PrismLauncher
      self.nixosModules.ProtonPlus
      self.nixosModules.TorBrowser
      self.nixosModules.ZedEditor
    ];

    nixpkgs.config.allowUnfree = true; # NOTE: needed because of veracrypt
    nixpkgs.hostPlatform = "x86_64-linux";

    console.keyMap = "hu";
    networking.hostName = "framework16";
    hardware.cpu.amd.updateMicrocode = true;
    services.openssh.enable = false;

    services.resolved = {
      enable = true;
      settings.Resolve.FallbackDNS = ["9.9.9.9" "1.1.1.1" "1.0.0.1"];
    };
    networking.networkmanager.dns = "systemd-resolved";

    nixcfgs = {
      username = "csd4ni3l";
      git_email = "csd4ni3l_contact.ladle014@passmail.com";
      git_username = "csd4ni3l";
      kernel_module_lock = true;
      firefox_full_dev_access = true; # changed my mind, for me, its a fair tradeoff between security and convenience
      firefox_cookie_allowlist = let
        origins = [
          "slack.com"
          "csd4ni3l.hu"
          "proton.me"
          "fluxer.app"
          "hackclub.com"
          "discord.com"
          "dino.icu"
          "tryhackme.com"
          "hackthebox.com"
        ];
      in
        lib.flatten (map (o: ["https://${o}" "http://${o}"]) origins);
    };

    home-manager.users."csd4ni3l" = import ../../../home/framework16.nix;
  };
}
