{self, ...}: {
  flake.nixosModules.DeckCraft = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [".config/deckcraft" ".local/share/deckcraft"];

    environment.systemPackages = [
      (jail.mkSandboxed self.packages.${pkgs.system}.craft-deckcraft "deckcraft"
        (with jail.combinators; [
          default # NOTE: no network, so slide show audio goes through the pulse socket only
          (rw-bind (noescape "~/.config/deckcraft") (noescape "~/.config/deckcraft"))
          (rw-bind (noescape "~/.local/share/deckcraft") (noescape "~/.local/share/deckcraft"))
          (rw-bind (noescape "~/Documents") (noescape "~/Documents"))
          (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        ]))
    ];
  };
}
