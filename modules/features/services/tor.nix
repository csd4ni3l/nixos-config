{...}: {
  flake.nixosModules.tor = {...}: {
    services.tor = {
      enable = true;
      client.enable = true;
      client.socksListenAddress = { addr = "127.0.0.1"; port = 9050; };
    };
  };
}
