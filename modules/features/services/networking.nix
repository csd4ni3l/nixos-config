{...}: {
  flake.nixosModules.networking = {...}: {
    networking = {
      modemmanager.enable = false;
      firewall.enable = true;
      networkmanager = {
        enable = true;
        wifi.powersave = false;
      };
    };
  };
}
