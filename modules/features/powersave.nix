{self, ...}: {
  flake.nixosModules.powersave = {
    pkgs, config, ...
  }: {
    services.power-profiles-daemon.enable = true;
    services.lact.enable = true;
    powerManagement.powertop.enable = true;
    # hardware.amdgpu.overdrive.enable = true;
  };
}
