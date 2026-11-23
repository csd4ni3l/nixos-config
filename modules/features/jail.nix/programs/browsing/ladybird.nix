{self, ...}: {
  flake.nixosModules.Ladybird = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
    ladybird = self.packages.${pkgs.system}.ladybird;

    # NOTE: Ladybird's own Landlock/seccomp sandbox only exposes FHS paths to the
    # helpers, so they cannot load store libs or /run/opengl-driver and GPU
    # initialisation fails. bwrap already isolates the app here.
    unsandboxed = pkgs.symlinkJoin {
      name = "ladybird";
      paths = [
        (pkgs.writeShellScriptBin "ladybird" ''
          exec ${ladybird}/bin/ladybird --disable-sandbox "$@"
        '')
        ladybird
      ];
      meta.mainProgram = "ladybird";
    };
  in {
    nixcfgs.jail_dirs = [
      ".cache/Ladybird"
      ".config/Ladybird"
      ".local/share/Ladybird"
    ];

    environment.systemPackages = [
      (jail.mkSandboxed unsandboxed "ladybird"
        (with jail.combinators; [
          default
          network
          # NOTE: the bundle only ships the Fusion and Windows Qt styles.
          (set-env "QT_STYLE_OVERRIDE" "Fusion")
          (rw-bind (noescape "~/.config/Ladybird") (noescape "~/.config/Ladybird"))
          (rw-bind (noescape "~/.local/share/Ladybird") (noescape "~/.local/share/Ladybird"))
          (rw-bind (noescape "~/.cache/Ladybird") (noescape "~/.cache/Ladybird"))
          (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        ]))
    ];
  };
}
