# NOTE: these were running as untrusted podman workloads that used the podman socket directly,
# so they ran under a separate unprivileged (guest) user for maximum security.
# They are now native systemd user services running as the guest user.
{
  self,
  config,
  pkgs,
  ...
}: {
  home.username = "guest";
  home.homeDirectory = "/home/guest";

  imports = [
    self.homeModules.options
    ./modules/common/default.nix
    ./modules/server/base.nix
  ];

  sops.defaultSopsFile = ../modules/hosts/publicvm/secrets/guest.yml;

  sops.secrets = {
    "pelican-wings-node-id" = {};
    "pelican-wings-token-id" = {};
    "pelican-wings-token" = {};
    "pelican-wings-panel" = {};
    "forgejo-runner-connection-url" = {};
    "forgejo-runner-uuid" = {};
    "forgejo-runner-token" = {};
  };

  sops.templates = {
    "pelican-wings-config" = {
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

    "forgejo-runner-config" = {
      path = "${"/run/user/1002"}/forgejo-runner/runner-config.yml";
      content = ''
        log:
          level: info
          job_level: info

        runner:
          file: .runner
          capacity: 1
          timeout: 3h
          shutdown_timeout: 3h
          insecure: false
          fetch_timeout: 30s
          fetch_interval: 2s
          report_interval: 1s
          labels:
            - ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest

        container:
          network: ""
          enable_ipv6: false
          privileged: false
          options:
          workdir_parent: /var/lib/forgejo-runner/workdir
          valid_volumes: []
          docker_host: unix:///run/user/1002/podman/podman.sock
          force_pull: false
          force_rebuild: false

        host:
          workdir_parent: /var/lib/forgejo-runner/workdir

        server:
          connections:
            forgejo:
              url: ${config.sops.placeholder."forgejo-runner-connection-url"}
              uuid: ${config.sops.placeholder."forgejo-runner-uuid"}
              token: ${config.sops.placeholder."forgejo-runner-token"}
      '';
    };
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

  systemd.user.services.forgejo-runner = {
    Unit = {
      Description = "Forgejo actions runner";
      After = ["sops-nix.service" "network-online.target"];
      Wants = ["sops-nix.service"];
    };
    Service = {
      Type = "simple";
      WorkingDirectory = "/var/lib/forgejo-runner";
      ExecStart = "${pkgs.forgejo-runner}/bin/forgejo-runner daemon --config /run/user/1002/forgejo-runner/runner-config.yml";
      Restart = "on-failure";
      RestartSec = "5s";
      Environment = [
        "DOCKER_HOST=unix:///run/user/1002/podman/podman.sock"
        "HOME=/var/lib/forgejo-runner"
      ];
      NonBlocking = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = ["/var/lib/forgejo-runner" "/run/user/1002/forgejo-runner"];
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
