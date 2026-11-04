{self, ...}: {
  flake.nixosModules.PearDesktop = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [".config/pear-desktop"];

    environment.systemPackages = [
      (jail.mkSandboxed pkgs.pear-desktop "pear-desktop" (with jail.combinators; [
        default
        network

        # NOTE: the config path contains a space, so it has to be quoted for bash
        (rw-bind (noescape "~/.config/pear-desktop") (noescape "\"$HOME/.config/YouTube Music\""))

        # NOTE: required for MPRIS / media keys
        (dbus {
          own = ["org.mpris.MediaPlayer2.YouTubeMusic"];
        })
      ]))
    ];
  };
}
