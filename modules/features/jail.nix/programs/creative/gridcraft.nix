{self, ...}: {
  flake.nixosModules.GridCraft = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [".config/gridcraft" ".local/share/gridcraft"];

    environment.systemPackages = [
      (jail.mkSandboxed self.packages.${pkgs.system}.craft-gridcraft "gridcraft"
        (with jail.combinators; [
          default
          (rw-bind (noescape "~/.config/gridcraft") (noescape "~/.config/gridcraft"))
          (rw-bind (noescape "~/.local/share/gridcraft") (noescape "~/.local/share/gridcraft"))
          (rw-bind (noescape "~/Documents") (noescape "~/Documents"))
          (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        ]))
    ];
  };
}
