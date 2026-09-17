{
  self,
  ...
}: {
  flake.nixosModules.crowdsec = {...}: {
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
        # traefik access logs written by the pangolin container
        {
          source = "file";
          filenames = ["/home/deploy/containers/pangolin/config/traefik/logs/*.log"];
          labels = {type = "traefik";};
        }
        # mariadb error log written by the mariadb container
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
          # pangolin's crowdsec container already binds 127.0.0.1:8080
          listen_uri = "127.0.0.1:8090";
        };
      };
    };

    # Block malicious IPs directly in the firewall using iptables
    services.crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        mode = "iptables";
        api_url = "http://127.0.0.1:8090";
      };
    };
  };
}
