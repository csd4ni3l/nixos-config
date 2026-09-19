{...}: {
  flake.nixosModules.ssh = {config, ...}: {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = ["${config.nixcfgs.username}"];
        MaxAuthTries = 3;
        PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
        LoginGraceTime = 30;
        MaxStartups = "10:30:100";
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        DisableForwarding = true;
        PermitTunnel = "no";
      };
    };
  };
}
