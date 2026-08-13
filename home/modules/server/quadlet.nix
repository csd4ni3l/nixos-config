{config, ...}: {
  systemd.user.services.enable-quadlets = {
    Unit = {
      Description = "Enable rootless Podman quadlet units";
      After = ["sops-nix.service"];
      Wants = ["sops-nix.service"];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/.config/systemd/user/quadlet-enable.sh";
    };

    Install.WantedBy = ["default.target"];
  };

  home.file.".config/systemd/user/quadlet-enable.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      quadlet_dir="${config.home.homeDirectory}/.config/containers/systemd"

      systemctl --user daemon-reload

      if [[ ! -d "$quadlet_dir" ]]; then
        exit 0
      fi

      for file in "$quadlet_dir"/*; do
        [[ -e "$file" ]] || continue

        name="$(basename "$file")"
        case "$name" in
          *.container)
            unit="''${name%.container}.service"
            ;;
          *.network)
            unit="$name"
            ;;
          *.volume)
            unit="$name"
            ;;
          *)
            continue
            ;;
        esac

        systemctl --user enable "$unit" >/dev/null 2>&1 || true
      done
    '';
  };
}
