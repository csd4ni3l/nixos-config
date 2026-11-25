{self, ...}: {
  flake.nixosModules.OpenCode = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [
      ".cache/opencode"
      ".config/opencode"
      ".local/share/opencode"
      ".local/state/opencode"
      ".wakatime"
    ];

    environment.systemPackages = [
      (jail.mkSandboxed pkgs.opencode "opencode" (with jail.combinators; [
        common-access
        network
        mount-cwd
        (ro-bind "${pkgs.coreutils}/bin/env" "/usr/bin/env")
        (rw-bind (noescape "~/.cache/opencode") (noescape "~/.cache/opencode"))
        (rw-bind (noescape "~/.config/opencode") (noescape "~/.config/opencode"))
        (rw-bind (noescape "~/.local/share/opencode") (noescape "~/.local/share/opencode"))
        (rw-bind (noescape "~/.local/state/opencode") (noescape "~/.local/state/opencode"))
        (rw-bind (noescape "~/.wakatime") (noescape "~/.wakatime"))
        (try-ro-bind (noescape "~/.wakatime.cfg") (noescape "~/.wakatime.cfg"))
        (try-ro-bind (noescape "~/.config/sops-nix/secrets/rendered/wakatime-cfg") (noescape "~/.config/sops-nix/secrets/rendered/wakatime-cfg"))
      ]))
    ];
  };
}
