{self, ...}: {
  flake.nixosModules.ZedEditor = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
    zeditor = pkgs.symlinkJoin {
      name = "zeditor";
      paths = [
        (pkgs.writeShellScriptBin "zeditor" ''
          exec ${pkgs.zed-editor}/bin/zeditor --foreground "$@"
        '')
        pkgs.zed-editor
      ];
      meta.mainProgram = "zeditor";
    };
  in {
    environment.systemPackages = [
      (jail.mkSandboxed zeditor "zeditor" (with jail.combinators; [
        default
        network

        (rw-bind (noescape "~/Projects") (noescape "~/Projects"))
        (rw-bind (noescape "~/Documents") (noescape "~/Documents"))
        (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))

        (rw-bind (noescape "~/.go") (noescape "~/.go"))
        (rw-bind (noescape "~/.cache/go-build") (noescape "~/.cache/go-build"))

        (rw-bind (noescape "~/.cargo") (noescape "~/.cargo"))
        (rw-bind (noescape "~/.rustup") (noescape "~/.rustup"))

        (rw-bind (noescape "~/.cache/uv") (noescape "~/.cache/uv"))
        (rw-bind (noescape "~/.local/share/uv") (noescape "~/.local/share/uv"))

        (rw-bind (noescape "~/.cache/ccache") (noescape "~/.cache/ccache"))

        (rw-bind (noescape "~/.config/zed") (noescape "~/.config/zed"))
        (rw-bind (noescape "~/.config/zsh") (noescape "~/.config/zsh"))
        (rw-bind (noescape "~/.local/share/zed") (noescape "~/.local/share/zed"))
        (rw-bind (noescape "~/.wakatime") (noescape "~/.wakatime"))

        (try-ro-bind (noescape "~/.config/git") (noescape "~/.config/git"))
        (try-ro-bind (noescape "~/.wakatime.cfg") (noescape "~/.wakatime.cfg"))
        (try-ro-bind (noescape "~/.config/sops-nix/secrets/rendered/wakatime-cfg") (noescape "~/.config/sops-nix/secrets/rendered/wakatime-cfg"))
      ]))
    ];
  };
}
