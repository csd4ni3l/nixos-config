{
  self,
  ...
}: {
  flake.nixosModules.crowdsec = {lib, ...}: {
    services.crowdsec = {
      enable = true;
      autoUpdateService = true;
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
        capi.credentialsFile = "/var/lib/crowdsec/online_api_credentials.yaml";
        general.api.server = {
          enable = true;
          listen_uri = "127.0.0.1:8090";
          disable_usage_metrics_export = true;
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

    systemd.services.crowdsec-firewall-bouncer-register.serviceConfig.DynamicUser = lib.mkForce false;
    systemd.services.crowdsec-firewall-bouncer-register.serviceConfig.SystemCallFilter = lib.mkForce [];

    systemd.tmpfiles.rules = ["d /var/lib/crowdsec 0750 crowdsec crowdsec"];

    users.users.crowdsec.extraGroups = ["deploy"];

    systemd.services.crowdsec.serviceConfig.SystemCallFilter = lib.mkForce [];
    systemd.services.crowdsec.serviceConfig.ProtectHome = lib.mkForce "read-only";
  };
}
