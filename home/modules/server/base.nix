{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  quadletReloadScript = pkgs.writeShellScript "quadlet-reload" ''
    systemctl='${pkgs.systemd}/bin/systemctl'
    "$systemctl" --user daemon-reload
    restart=false
    for c in '${config.home.homeDirectory}'/.config/containers/systemd/*.container; do
      [[ -e "$c" ]] || continue
      unit="$(basename "$c" .container).service"
      if ! "$systemctl" --user is-active --quiet "$unit" 2>/dev/null; then
        restart=true
        break
      fi
    done
    if [[ "$restart" == true ]]; then
      "$systemctl" --user restart default.target
    fi
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

    systemd.user.paths.quadlet-reload = {
      Unit.Description = "Watch for podman quadlet file changes";
      Path.PathChanged = "%h/.config/containers/systemd";
      Install.WantedBy = ["default.target"];
    };

    systemd.user.services.quadlet-reload = {
      Unit.Description = "Reload podman quadlet units";
      Service = {
        Type = "oneshot";
        ExecStart = "${quadletReloadScript}";
      };
    };

    home.stateVersion = "26.11";
  };
}
