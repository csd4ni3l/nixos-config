{self, ...}: {
  flake.nixosModules.wings = {
    config,
    inputs,
    pkgs,
    ...
  }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops = {
      age.keyFile = "/persist/home/guest/.config/sops/age/keys.txt";
      age.sshKeyPaths = [];
      secrets."pelican-wings-node-id" = {
        sopsFile = ../../hosts/publicvm/secrets/guest.yml;
      };
      secrets."pelican-wings-token-id" = {
        sopsFile = ../../hosts/publicvm/secrets/guest.yml;
      };
      secrets."pelican-wings-token" = {
        sopsFile = ../../hosts/publicvm/secrets/guest.yml;
      };
      secrets."pelican-wings-panel" = {
        sopsFile = ../../hosts/publicvm/secrets/guest.yml;
      };

      templates."pelican-wings-config" = {
        path = "/run/pelican/config.yml";
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

          allowed_mounts: []
          BlockBaseDirMount: true
        '';
      };
    };

    systemd.services.wings = {
      description = "Pelican Wings daemon";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "simple";
        User = "guest";
        Group = "users";
        ExecStart = "${self.packages.${pkgs.system}.pelican-wings}/bin/wings --config /run/pelican/config.yml";
        Restart = "on-failure";
        RestartSec = "5s";
        Environment = [
          "TZ=Europe/Budapest"
          "DOCKER_HOST=unix:///run/user/1002/podman/podman.sock"
        ];
        NonBlocking = true;
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        ProtectSystem = "strict";
        ProtectHome = "read-only";
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
    };

    systemd.tmpfiles.rules = [
      "d /run/pelican 0755 root root -"
      "d /var/lib/pelican 0700 guest users -"
      "d /var/lib/pelican/volumes 0700 guest users -"
      "d /var/lib/pelican/archives 0700 guest users -"
      "d /var/lib/pelican/backups 0700 guest users -"
      "d /var/lib/pelican/machine-id 0700 guest users -"
      "d /var/log/pelican 0750 guest users -"
    ];
  };
}
