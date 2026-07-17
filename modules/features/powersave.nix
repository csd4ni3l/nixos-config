{self, ...}: {
  flake.nixosModules.powersave = {
    pkgs, lib, ...
  }: {
    services.power-profiles-daemon.enable = true;
    services.lact.enable = true;
    powerManagement.powertop.enable = true;
    # hardware.amdgpu.overdrive.enable = true;
  };
}
