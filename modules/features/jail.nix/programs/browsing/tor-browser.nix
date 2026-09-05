{self, ...}: {
  flake.nixosModules.TorBrowser = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (jail.mkSandboxed pkgs.tor-browser "tor-browser"
        (with jail.combinators; [
          default
          network
          (unsafe-add-raw-args "--bind-try \"$HOME/.config/tor-browser\" \"$HOME/.tor project\"")
        ]))
    ];
  };
}
