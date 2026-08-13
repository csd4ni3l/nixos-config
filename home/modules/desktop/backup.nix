{
  pkgs,
  config,
  ...
}: let
  backupScript = pkgs.writeShellScript "proxmox-backup-hourly" ''
        exec ${pkgs.python3}/bin/python3 << 'PYEOF'
    import tomllib
    import os
    import subprocess

    with open("${config.sops.templates."backup-config.toml".path}", "rb") as f:
        cfg = tomllib.load(f)

    env = os.environ.copy()
    env["PBS_REPOSITORY"] = f"{cfg['user']}@{cfg['host']}:{cfg['datastore']}"
    env["PBS_PASSWORD"] = cfg["password"]

    subprocess.run(
        [
            "proxmox-backup-client",
            "backup",
            "root.pxar:/persist/home/${config.nixcfgs.username}",
            "--exclude", ".var/app",
            "--exclude", ".local/share/Steam",
            "--exclude", ".local/share/uv",
            "--exclude", ".local/share/anime-game-launcher",
            "--exclude", ".local/share/flatpak",
            "--exclude", ".local/share/PrismLauncher",
            "--exclude", ".rustup/toolchains",
            "--exclude", ".rustup/update-hashes",
            "--exclude", "*venv*",
            "--exclude", "*cache*",
            "--exclude", "*Cache*",
            "--exclude", "*target*",
            "--exclude", cfg["keyfile"].replace("/home/${config.nixcfgs.username}/", ""),
            "--keyfile", cfg["keyfile"],
        ],
        env=env,
        check=True,
    )
    PYEOF
  '';
in {
  sops.secrets = {
    "pbs-user" = {};
    "pbs-host" = {};
    "pbs-datastore" = {};
    "pbs-keyfile" = {};
    "pbs-password" = {mode = "0400";};
  };

  sops.templates."backup-config.toml" = {
    content = ''
      user = "${config.sops.placeholder."pbs-user"}"
      host = "${config.sops.placeholder."pbs-host"}"
      datastore = "${config.sops.placeholder."pbs-datastore"}"
      password = "${config.sops.placeholder."pbs-password"}"
      keyfile = "${config.sops.placeholder."pbs-keyfile"}"
    '';
  };

  systemd.user.services.proxmox-backup-hourly = {
    Unit = {
      Description = "Proxmox backup";
    };
    Service = {
      Type = "oneshot";
      ExecStart = backupScript;
    };
  };

  systemd.user.timers.proxmox-backup-hourly = {
    Unit = {
      Description = "Hourly Proxmox backup";
    };
    Timer = {
      OnCalendar = "hourly";
      Persistent = true;
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };
}
