{self, ...}: {
  flake.nixosModules.Supersonic = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [".config/supersonic" ".cache/supersonic"];

    environment.systemPackages = [
      (jail.mkSandboxed pkgs.supersonic "supersonic" (with jail.combinators; [
        default
        network

        # NOTE: required for MPRIS
        (rw-bind (noescape "~/.cache/supersonic") (noescape "~/.cache/supersonic"))

        (dbus {
          own = [
            "org.mpris.MediaPlayer2.Supersonic"
            "org.mpris.MediaPlayer2.Supersonic.*"
          ];
        })

        (rw-bind (noescape "~/.config/supersonic") (noescape "~/.config/supersonic"))
        (rw-bind (noescape "~/Music") (noescape "~/Music"))
      ]))
    ];
  };
}
