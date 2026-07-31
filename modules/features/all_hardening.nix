{self, ...}: {
  flake.nixosModules.AllHardening = {...}: {
    imports = [
      self.nixosModules.HardeningKernel
      self.nixosModules.HardeningMisc
      self.nixosModules.HardeningNoSUID
      self.nixosModules.HardeningServices
      self.nixosModules.HardeningSysCtl
      self.nixosModules.HardeningUSBGuard
    ];
  };
}
