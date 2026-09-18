{self, pkgs, config, ...}: {
  sops.secrets = {
    "pelican-wings-node-id" = {};
    "pelican-wings-token-id" = {};
    "pelican-wings-token" = {};
    "pelican-wings-panel" = {};
  };

  sops.templates."pelican-wings-config" = {
    path = "${"/run/user/1002"}/pelican/config.yml";
    content = ''
      app_name: "pelican"
      uuid: ${config.sops.placeholder."pelican-wings-node-id"}
      token_id: ${config.sops.placeholder."pelican-wings-token-id"}
      token: ${config.sops.placeholder."pelican-wings-token"}
      remote: "https://${config.sops.placeholder."pelican-wings-panel"}"

      api:
        host: "0.0.0.0"
        port: 54001
        ssl:
          enabled: false

      system:
        root_directory: "/var/lib/pelican"
        log_directory: "/var/log/pelican"
        data: "/var/lib/pelican/volumes"
        archive_directory: "/var/lib/pelican/archives"
        backup_directory: "/var/lib/pelican/backups"
        tmp_directory: "/tmp/pelican"
        username: "guest"
        timezone: "Europe/Budapest"
        user:
          rootless:
            enabled: true
            container_uid: 0
            container_gid: 0
          uid: 1002
          gid: 100
        machine_id:
          enable: true
          directory: "/var/lib/pelican/machine-id"

      docker:
        network:
          enabled: true
          name: "pelican_nw"
          driver: "bridge"
        log_config:
          type: "k8s-file"
          config:
            max-size: "5m"
            max-file: "1"
            mode: "non-blocking"

      allowed_mounts: []
      BlockBaseDirMount: true
    '';
  };

  systemd.user.services.wings = {
    Unit = {
      Description = "Pelican Wings daemon";
      After = ["sops-nix.service" "network-online.target"];
      Wants = ["sops-nix.service"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${self.packages.${pkgs.system}.pelican-wings}/bin/wings --config /run/user/1002/pelican/config.yml";
      Restart = "on-failure";
      RestartSec = "5s";
      Environment = [
        "TZ=Europe/Budapest"
        "DOCKER_HOST=unix:///run/user/1002/podman/podman.sock"
      ];
      NonBlocking = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = [
        "/var/lib/pelican"
        "/var/log/pelican"
        "/etc/pelican"
        "/run/user/1002/pelican"
        "/home/guest/.local/share/containers"
      ];
      ProtectKernelTunables = true;
      ProtectKernelLogs = true;
      ProtectClock = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";
      NoNewPrivileges = true;
      RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      RestrictNamespaces = true;
      LockPersonality = true;
      UMask = "0077";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
