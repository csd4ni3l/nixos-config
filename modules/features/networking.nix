{...}: {
  flake.nixosModules.networking = {...}: {
    networking = {
      modemmanager.enable = false;
      firewall.enable = true;
      networkmanager = {
        enable = true;
        ethernet.macAddress = "random";

        wifi = {
          powersave = false;
          scanRandMacAddress = true;
          macAddress = "random";
        };
      };
    };
  };
}
