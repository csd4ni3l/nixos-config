{self, ...}: {
  flake.nixosModules.FluxerCanary = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [".config/fluxer"];

    environment.systemPackages = [
      (jail.mkSandboxed self.packages.${pkgs.system}.fluxer-canary "fluxer-canary"
        (with jail.combinators; [
          keyring-access
          default
          network
          (rw-bind (noescape "~/.config/fluxer") (noescape "~/.config/fluxer"))
          (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        ]))
    ];
  };
}
