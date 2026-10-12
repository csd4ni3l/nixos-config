{self, ...}: {
  flake.nixosModules.FluxerCanary = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [".config/fluxercanary"];

    environment.systemPackages = [
      (jail.mkSandboxed self.packages.${pkgs.system}.fluxer-canary "fluxer-canary"
        (with jail.combinators; [
          default
          network
          (rw-bind (noescape "~/.config/fluxercanary") (noescape "~/.config/fluxercanary"))
          (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        ]))
    ];
  };
}
