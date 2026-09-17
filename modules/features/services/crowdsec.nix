{
  self,
  ...
}: {
  flake.nixosModules.crowdsec = {lib, ...}: {
    # NOTE: crowdsec wants to set the running user's description to be "CrowdSec service user", which conflicts with NixOS default.
    users.users.root.description = lib.mkForce "System administrator";

    services.crowdsec = {
      enable = true;
      autoUpdateService = true;

      # run as root so journald and the deploy user's container logs are readable
      user = "root";
      group = "root";

      hub.collections = [
        "crowdsecurity/linux"
        "crowdsecurity/traefik"
        "crowdsecurity/mariadb"
      ];

      localConfig.acquisitions = [
        {
          source = "journalctl";
          journalctl_filter = ["_SYSTEMD_UNIT=sshd.service"];
          labels = {type = "syslog";};
        }
        {
          source = "file";
          filenames = ["/home/deploy/containers/pangolin/config/traefik/logs/*.log"];
          labels = {type = "traefik";};
        }
        {
          source = "file";
          filenames = ["/home/deploy/containers/mariadb/log/mysql/*.log"];
          labels = {type = "mariadb";};
        }
      ];

      settings = {
        lapi.credentialsFile = "/var/lib/crowdsec/local_api_credentials.yaml";
        general.api.server = {
          enable = true;
          listen_uri = "127.0.0.1:8090";
        };
      };
    };

    services.crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        mode = "iptables";
        api_url = "http://127.0.0.1:8090";
      };
    };

    systemd.services.crowdsec.serviceConfig.SystemCallFilter = lib.mkForce [];
    systemd.services.crowdsec-firewall-bouncer-register.serviceConfig.SystemCallFilter = lib.mkForce [];
    systemd.services.crowdsec.serviceConfig.ProtectHome = lib.mkForce false;
  };
}
