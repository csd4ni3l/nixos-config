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
      self.nixosModules.virtualisation
      self.nixosModules.powersave
      self.nixosModules.bootloader
      self.nixosModules.disko
      self.nixosModules.compatibility
      self.nixosModules.bluetooth
      self.nixosModules.networking
      self.nixosModules.zram

      # hardening
      self.nixosModules.HardeningKernel
      self.nixosModules.HardeningMisc
      self.nixosModules.HardeningNoSUID
      self.nixosModules.HardeningServices
      self.nixosModules.HardeningSysCtl
      self.nixosModules.HardeningUSBGuard
      self.nixosModules.HardeningFaillock

      # framework stuff
      self.nixosModules.FrameworkControl
      self.nixosModules.Framework16Boot
      self.nixosModules.Framework16USBGuard

      # nixpak apps
      self.nixosModules.nixpak
      self.nixosModules.Mpv
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

    nixcfgs = {
      username = "csd4ni3l";
      git_email = "csd4ni3l_contact.ladle014@passmail.com";
      git_username = "csd4ni3l";
      firefox_full_dev_access = false;
      firefox_cookie_allowlist = let
        origins = [
          "slack.com"
          "csd4ni3l.hu"
          "navi.csd4ni3l.hu"
          "rss.csd4ni3l.hu"
          "aonsoku.home.csd4ni3l.hu"
          "proton.me"
          "mail.proton.me"
          "drive.proton.me"
          "lumo.proton.me"
          "web.canary.fluxer.app"
          "todo.csd4ni3l.hu"
          "hackclub.com"
          "discord.com"
          "libreassistant.dino.icu"
          "tryhackme.com"
          "hackthebox.com"
          "app.hackthebox.com"
        ];
      in
        lib.flatten (map (o: ["https://${o}" "http://${o}"]) origins);
    };
  };
}
