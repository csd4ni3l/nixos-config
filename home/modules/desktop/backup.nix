{
  pkgs,
  config,
  ...
}: let
  backupScript = pkgs.writeShellScript "proxmox-backup-hourly" ''
    exec ${pkgs.python3}/bin/python3 << 'PYEOF'
    import os
    import subprocess
    import sys
    import time
    import tomllib

    NOTIFY = "${pkgs.libnotify}/bin/notify-send"
    DU = "${pkgs.coreutils}/bin/du"
    SOURCE = "/persist/home/${config.nixcfgs.username}"
    CONFIG_PATH = "${config.sops.templates."backup-config.toml".path}"
    MAX_BACKUP_BYTES = 20 * 1024 ** 3
    EXCLUDES = [
        ".var/app",
        ".local/share/Steam",
        ".local/share/uv",
        ".local/share/anime-game-launcher",
        ".local/share/PrismLauncher",
        ".rustup/toolchains",
        ".rustup/update-hashes",
        "*venv*",
        "*cache*",
        "*Cache*",
        "*target*",
        "*.iso",
        "*.qcow2",
        "Documents/firefox",
    ]

    def notify(title, body, urgency="normal"):
        try:
            subprocess.run(
                [
                    NOTIFY,
                    "--app-name=Proxmox Backup",
                    f"--urgency={urgency}",
                    title,
                    body,
                ],
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except Exception as exc:
            print(f"Failed to send notification: {exc}", file=sys.stderr)

    def human_size(size):
        for unit in ("B", "KiB", "MiB", "GiB", "TiB"):
            if size < 1024 or unit == "TiB":
                return f"{size:.1f} {unit}"
            size /= 1024

    def backup_size(cfg):
        excludes = EXCLUDES + [
            cfg["keyfile"].replace("/home/${config.nixcfgs.username}/", "")
        ]
        result = subprocess.run(
            [DU, "-sb", *[f"--exclude={pattern}" for pattern in excludes], SOURCE],
            check=True,
            capture_output=True,
            text=True,
        )
        return int(result.stdout.split()[0])

    def main():
        with open(CONFIG_PATH, "rb") as f:
            cfg = tomllib.load(f)

        env = os.environ.copy()
        env["PBS_REPOSITORY"] = f"{cfg['user']}@{cfg['host']}:{cfg['datastore']}"
        env["PBS_PASSWORD"] = cfg["password"]

        size = backup_size(cfg)
        size_human = human_size(size)

        if size > MAX_BACKUP_BYTES:
            raise RuntimeError(
                f"Backup size {size_human} exceeds the 20 GiB limit"
            )

        notify("Proxmox backup started", f"Backing up {size_human}")

        started = time.monotonic()
        subprocess.run(
            [
                "proxmox-backup-client",
                "backup",
                "root.pxar:/persist/home/${config.nixcfgs.username}",
                "--exclude", ".var/app",
                "--exclude", ".local/share/Steam",
                "--exclude", ".local/share/uv",
                "--exclude", ".local/share/anime-game-launcher",
                "--exclude", ".local/share/PrismLauncher",
                "--exclude", ".rustup/toolchains",
                "--exclude", ".rustup/update-hashes",
                "--exclude", "*venv*",
                "--exclude", "*cache*",
                "--exclude", "*Cache*",
                "--exclude", "*target*",
                "--exclude", "*.iso",
                "--exclude", "*.qcow2",
                "--exclude", "Documents/firefox",
                "--exclude", cfg["keyfile"].replace("/home/${config.nixcfgs.username}/", ""),
                "--keyfile", cfg["keyfile"],
            ],
            env=env,
            check=True,
        )
        elapsed = time.monotonic() - started

        notify(
            "Proxmox backup finished",
            f"Backed up {size_human} in {elapsed:.0f}s",
        )

    try:
        main()
    except Exception as exc:
        notify("Proxmox backup failed", str(exc), urgency="critical")
        raise
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
