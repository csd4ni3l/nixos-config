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
    nixos_rebuild=${pkgs.nixos-rebuild}/bin/nixos-rebuild

    if [[ ! -e $repo/.git ]]; then
      $git clone "$url" "$repo"
    fi

    if [[ ! -w $repo/.git ]]; then
      echo "rebuild: $repo is not writable by $(id -un)" >&2
      echo "  the clone predates this command and is still owned by root:" >&2
      echo "  run0 chown -R $(id -un) $repo" >&2
      exit 1
    fi

    old=$($git -C "$repo" rev-parse HEAD)

    if [[ $pull == true ]]; then
      $git -C "$repo" pull --ff-only
    fi

    new=$($git -C "$repo" rev-parse HEAD)

    oldshort=$(printf %.12s "$old")
    newshort=$(printf %.12s "$new")

    dirty=$($git -C "$repo" status --porcelain)
    review=false

    if [[ -n $dirty ]]; then
      review=true
      echo "rebuild: working tree is modified, this gets built too:" >&2
      echo "$dirty" >&2
      echo >&2
    fi

    if [[ "$old" != "$new" ]]; then
      review=true
      echo "rebuild: $oldshort -> $newshort"
      echo
      $git -C "$repo" log --oneline --no-decorate "$old..$new"
      echo
      $git -C "$repo" diff --stat "$old..$new"
      echo
    else
      echo "rebuild: nothing new, switching to $newshort as is"
    fi

    if [[ $review == true ]]; then
      if [[ ! -t 0 ]]; then
        echo "rebuild: not a terminal, refusing to switch to unreviewed changes" >&2
        echo "  review them by hand, then rebuild again" >&2
        exit 1
      fi

      read -r -p "switch to $newshort? [y/N] " reply
      if [[ "$reply" != "y" && "$reply" != "Y" ]]; then
        echo "rebuild: aborted, staying on $oldshort" >&2
        exit 1
      fi
    fi

    run0 $nixos_rebuild switch \
        --flake "$repo$flake" \
        --no-reexec \
        --accept-flake-config
  '';
in {
  home.packages = [script];
}
