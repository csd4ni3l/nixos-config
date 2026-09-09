{self, ...}: {
  flake.nixosModules.PrismLauncher = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (jail.mkSandboxed pkgs.prismlauncher "prismlauncher" (with jail.combinators; [
        default
        network
        # NOTE: needs X11 for minecraft
        unsafe-x11

        (rw-bind (noescape "~/.local/share/PrismLauncher") (noescape "~/.local/share/PrismLauncher"))
      ]))
    ];
  };
}
