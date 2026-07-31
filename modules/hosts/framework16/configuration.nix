{self, ...}: {
  flake.nixosModules.framework16Configuration = {...}: {
    imports = [
      self.nixosModules.general
      self.nixosModules.desktop
      self.nixosModules.gaming
      self.nixosModules.impermanence
      self.nixosModules.virtualisation
      self.nixosModules.powersave
      self.nixosModules.secureboot
      self.nixosModules.disko
      self.nixosModules.compatibility
      self.nixosModules.FrameworkControl
      self.nixosModules.bluetooth
      self.nixosModules.networking
      self.nixosModules.zram
      self.nixosModules.AllHardening

      self.nixosModules.Framework16Boot
      self.nixosModules.Framework16USBGuard
    ];

    nixpkgs.config.allowUnfree = true; # NOTE: needed because of veracrypt
    nixpkgs.hostPlatform = "x86_64-linux";

    console.keyMap = "hu";
    networking.hostName = "framework16";
    hardware.cpu.amd.updateMicrocode = true;
  };
}
