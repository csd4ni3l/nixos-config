{...}: {
  flake.nixosModules.tor = {config, ...}: {
    users.users.${config.nixcfgs.username}.extraGroups = ["tor"];
    services.tor = {
      enable = true;
      client.enable = true;
      client.socksListenAddress = {
        addr = "127.0.0.1";
        port = 9050;
      };
      settings = {
        ControlPort = 9051;
        CookieAuthentication = true;
        CookieAuthFileGroupReadable = true;
      };
    };
  };
}
