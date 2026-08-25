{self, ...}: {
  flake.nixosModules.ObsStudio = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (jail.mkSandboxed pkgs.obs-studio "obs" (with jail.combinators; [
        default

        (rw-bind (noescape "~/Videos/OBS") (noescape "~/Videos/OBS"))
      ]))
    ];
  };
}
