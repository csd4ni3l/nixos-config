{
  inputs,
  config,
  lib,
  ...
}: {
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

    home.activation.reloadQuadletUnits = lib.hm.dag.entryAfter ["writeBoundary" "sops-nix"] ''
      if [[ -d "/run/user/$(id -u)/systemd" ]]; then
        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
        systemctl --user daemon-reload
        restart=false
        for c in '${config.home.homeDirectory}'/.config/containers/systemd/*.container; do
          [[ -e "$c" ]] || continue
          unit="$(basename "$c" .container).service"
          if ! systemctl --user is-active --quiet "$unit" 2>/dev/null; then
            restart=true
            break
          fi
        done
        if [[ "$restart" == true ]]; then
          systemctl --user restart default.target
        fi
      fi
    '';

    home.username = "deploy";
    home.homeDirectory = "/home/deploy";
    home.stateVersion = "26.11";

    sops.age = {
      keyFile = "/persist/home/deploy/.config/sops/age/keys.txt";
      sshKeyPaths = [];
    };
  };
}
