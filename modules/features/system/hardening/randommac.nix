{...}: {
  flake.nixosModules.HardeningRandomMAC = {...}: {
    networking = {
      networkmanager = {
        ethernet.macAddress = "random";
        wifi = {
          scanRandMacAddress = true;
          macAddress = "random";
        };
      };
      tempAddresses = "enabled";
    };
  };
}
