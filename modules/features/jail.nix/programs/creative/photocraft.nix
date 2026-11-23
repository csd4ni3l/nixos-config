{self, ...}: {
  flake.nixosModules.PhotoCraft = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [".config/photocraft" ".local/share/photocraft" "Pictures"];

    environment.systemPackages = [
      (jail.mkSandboxed self.packages.${pkgs.system}.craft-photocraft "photocraft"
        (with jail.combinators; [
          default
          (rw-bind (noescape "~/.config/photocraft") (noescape "~/.config/photocraft"))
          (rw-bind (noescape "~/.local/share/photocraft") (noescape "~/.local/share/photocraft"))
          (rw-bind (noescape "~/Pictures") (noescape "~/Pictures"))
          (rw-bind (noescape "~/Documents") (noescape "~/Documents"))
          (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        ]))
    ];
  };
}
