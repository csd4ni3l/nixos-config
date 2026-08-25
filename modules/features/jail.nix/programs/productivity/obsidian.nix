{self, ...}: {
  flake.nixosModules.Obsidian = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (jail.mkSandboxed pkgs.obsidian "obsidian" (with jail.combinators; [
        default

        (try-rw-bind (noescape "~/Documents/ObsidianVault") (noescape "~/Documents/ObsidianVault"))
      ]))
    ];
  };
}
