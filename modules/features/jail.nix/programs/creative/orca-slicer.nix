{self, ...}: {
  flake.nixosModules.OrcaSlicer = {
    pkgs,
    inputs,
    ...
  }: let
  jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [ (jail.mkSandboxed pkgs.orca-slicer "orca-slicer"
      (with jail.combinators; [
        default
        network # needed for printer conn
        (rw-bind (noescape "~/.config/OrcaSlicer") (noescape "~/.config/OrcaSlicer"))
        (rw-bind (noescape "~/Projects/3D") (noescape "~/Projects/3D"))
      ]))
    ];
  };
}
