{self, ...}: {
  flake.nixosModules.Mpv = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (jail.mkSandboxed pkgs.mpv "mpv" (with jail.combinators; [
        default
        network

        (try-ro-bind "/run/media" "/run/media")
        (ro-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        (ro-bind (noescape "~/Music") (noescape "~/Music"))
        (ro-bind (noescape "~/Videos") (noescape "~/Videos"))
      ]))
    ];
  };
}
