{self, ...}: {
  flake.nixosModules.Qalculate = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (jail.mkSandboxed pkgs.qalculate-qt "qalculate-qt" (with jail.combinators; [
        default
      ]))
    ];
  };
}
