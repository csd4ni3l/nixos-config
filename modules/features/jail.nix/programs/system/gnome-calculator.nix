{self, ...}: {
  flake.nixosModules.GnomeCalculator = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (jail.mkSandboxed pkgs.gnome-calculator "gnome-calculator" (with jail.combinators; [
        default
      ]))
    ];
  };
}
