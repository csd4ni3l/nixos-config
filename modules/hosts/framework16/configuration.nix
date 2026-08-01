{self, ...}: {
  flake.nixosModules.framework16Configuration = {...}: {
    imports = [
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

      self.nixosModules.HardeningKernel
      self.nixosModules.HardeningMisc
      self.nixosModules.HardeningNoSUID
      self.nixosModules.HardeningServices
      self.nixosModules.HardeningSysCtl
      self.nixosModules.HardeningUSBGuard

      self.nixosModules.FrameworkControl
      self.nixosModules.Framework16Boot
      self.nixosModules.Framework16USBGuard
    ];

    nixpkgs.config.allowUnfree = true; # NOTE: needed because of veracrypt
    nixpkgs.hostPlatform = "x86_64-linux";

    console.keyMap = "hu";
    networking.hostName = "framework16";
    hardware.cpu.amd.updateMicrocode = true;

    nixcfgs = {
      username = "csd4ni3l";
      git_email = "csd4ni3l_contact.ladle014@passmail.com";
      git_username = "csd4ni3l";
    };
  };
}
