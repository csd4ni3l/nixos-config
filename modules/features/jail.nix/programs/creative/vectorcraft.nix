{self, ...}: {
  flake.nixosModules.VectorCraft = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [".config/vectorcraft" ".local/share/vectorcraft" "Pictures"];

    environment.systemPackages = [
      (jail.mkSandboxed self.packages.${pkgs.system}.craft-vectorcraft "vectorcraft"
        (with jail.combinators; [
          default
          (rw-bind (noescape "~/.config/vectorcraft") (noescape "~/.config/vectorcraft"))
          (rw-bind (noescape "~/.local/share/vectorcraft") (noescape "~/.local/share/vectorcraft"))
          (rw-bind (noescape "~/Pictures") (noescape "~/Pictures"))
          (rw-bind (noescape "~/Documents") (noescape "~/Documents"))
          (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        ]))
    ];
  };
}
