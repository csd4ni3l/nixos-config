{
  pkgs,
  config,
  ...
}: let
  repo = "/home/${config.home.username}/nixos-config";
  url = "https://git.csd4ni3l.hu/csd4ni3l/nixos-config.git";

  script = pkgs.writeShellScriptBin "rebuild" ''
    set -eu

    repo="${repo}"
    url="${url}"
    flake="#${config.nixcfgs.flake_host}"

    pull=true
    case "''${1:-}" in
      --no-pull) pull=false ;;
      -h | --help)
        echo "usage: rebuild [--no-pull]"
        echo
        echo "Pull $url into $repo and switch to it as root."
        echo "Pass --no-pull to rebuild the clone as it already is."
        exit 0
        ;;
    esac

    git=${pkgs.git}/bin/git
    flock=${pkgs.util-linux}/bin/flock
    nixos-rebuild=${pkgs.nixos-rebuild}/bin/nixos-rebuild

    if [[ ! -e $repo/.git ]]; then
      $git clone "$url" "$repo"
    fi

    if [[ ! -w $repo/.git ]]; then
      echo "rebuild: $repo is not writable by $(id -un)" >&2
      echo "  the clone predates this command and is still owned by root:" >&2
      echo "  run0 chown -R $(id -un) $repo" >&2
      exit 1
    fi

    if [[ $pull == true ]]; then
      $git -C "$repo" pull --ff-only
    fi

    run0 $nixos-rebuild switch \
        --flake "$repo$flake" \
        --no-reexec \
        --accept-flake-config
  '';
in {
  home.packages = [script];
}
