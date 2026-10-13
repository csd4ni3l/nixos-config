{self, ...}: {
  flake.nixosModules.WordCraft = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [".config/wordcraft" ".local/share/wordcraft"];

    environment.systemPackages = [
      (jail.mkSandboxed self.packages.${pkgs.system}.craft-wordcraft "wordcraft"
        (with jail.combinators; [
          default
          (rw-bind (noescape "~/.config/wordcraft") (noescape "~/.config/wordcraft"))
          (rw-bind (noescape "~/.local/share/wordcraft") (noescape "~/.local/share/wordcraft"))
          (rw-bind (noescape "~/Documents") (noescape "~/Documents"))
          (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        ]))
    ];
  };
}
