{self, pkgs, config}: {
  sops.secrets = {
    "forgejo-runner-connection-url" = {};
    "forgejo-runner-uuid" = {};
    "forgejo-runner-token" = {};
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
