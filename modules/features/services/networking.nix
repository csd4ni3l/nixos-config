{lib, ...}: {
  flake.nixosModules.networking = {lib, ...}: {
    networking = {
      modemmanager.enable = false;
      firewall.enable = true;
      networkmanager = {
        enable = true;
        wifi.powersave = false;
      };
    };

    nixcfgs.impermanence.networking = lib.mkDefault true;
  };
}
