{self, ...}: {
  flake.nixosModules.BurpSuite = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
        (jail.mkSandboxed pkgs.burpsuite "burpsuite" (with jail.combinators; [
          default
          network
          (share-ns "user")
        ]))
    ];
  };
}
