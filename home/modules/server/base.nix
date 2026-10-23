{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  quadletDir = "${config.home.homeDirectory}/.config/containers/systemd";

  # Regenerate podman quadlet units and apply them to every enabled container:
  # - running containers are restarted so changed images/config take effect
  # - enabled-but-not-running containers (e.g. newly added) are started
  # - disabled containers are left alone
  quadletReloadScript = pkgs.writeShellScript "quadlet-reload" ''
    systemctl='${config.systemd.user.systemctlPath}'

    "$systemctl" --user daemon-reload

    for c in "${quadletDir}"/*.container; do
      [[ -e "$c" ]] || continue
      unit="$("${pkgs.coreutils}/bin/basename" "$c" .container).service"

      if "$systemctl" --user is-enabled --quiet "$unit" 2>/dev/null; then
        if "$systemctl" --user is-active --quiet "$unit" 2>/dev/null; then
          "$systemctl" --user restart "$unit"
        else
          "$systemctl" --user start "$unit"
        fi
      fi
    done
  '';
in {
  options.homelab.containerDirs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = ''
      Container data directories (absolute paths) to pre-create before
      podman quadlets start, instead of placing .keep marker files inside
      the container volumes.
    '';
  };

  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./impermanence.nix
  ];

  config = {
    home.activation.createContainerDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${lib.concatMapStringsSep "\n" (d: "mkdir -p '${d}'") config.homelab.containerDirs}
    '';

    home.activation.restartQuadlets = lib.hm.dag.entryAfter ["sops-nix"] ''
      systemctl='${config.systemd.user.systemctlPath}'
      status=$("$systemctl" --user is-system-running 2>&1 || true)
      if [[ "$status" == running || "$status" == degraded ]]; then
        ${quadletReloadScript}
      else
        echo "quadlet-reload: user systemd is not running, skipping container restart" >&2
      fi
    '';

    systemd.user.services.podman-prune = {
      Unit.Description = "Prune unused podman images";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.podman}/bin/podman system prune -af --filter until=72h";
      };
    };

    systemd.user.timers.podman-prune = {
      Unit.Description = "Podman image prune timer (every 3 days)";
      Timer = {
        OnCalendar = "*-*-*/3";
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };

    home.stateVersion = "26.11";
  };
}
