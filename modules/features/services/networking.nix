{...}: {
  flake.nixosModules.networking = {...}: {
    networking = {
      modemmanager.enable = false;
      firewall = {
        enable = true;
        logReversePathDrops = true;
        logRefusedConnections = false;
        allowedTCPPorts = [];
        allowedUDPPorts = [];
      };
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
