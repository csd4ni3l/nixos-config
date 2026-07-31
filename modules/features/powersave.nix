{self, ...}: {
  flake.nixosModules.powersave = {pkgs, ...}: {
    services.power-profiles-daemon.enable = true;
    services.lact.enable = true;
    powerManagement.powertop.enable = true;

    environment.systemPackages = with pkgs; [
      powertop
    ];
  };
}
