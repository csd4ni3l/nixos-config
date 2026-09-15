{...}: {
  flake.nixosModules.dnscrypt = {config, ...}: {
    services.dnscrypt-proxy = {
      enable = true;
      settings = {
        listen_addresses = ["127.0.0.1:53"];
        server_names = config.nixcfgs.dnscrypt_server_names;
      };
    };
  };
}
