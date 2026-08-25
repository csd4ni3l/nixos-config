{self, ...}: {
  flake.nixosModules.MoneroGui = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (jail.mkSandboxed pkgs.monero-gui "monero-wallet-gui" (with jail.combinators; [
        default
        network

        (rw-bind (noescape "~/.bitmonero") (noescape "~/.bitmonero"))
        (rw-bind (noescape "~/.p2pool") (noescape "~/.p2pool"))
        (rw-bind (noescape "~/Documents/Monero") (noescape "~/Documents/Monero"))
      ]))
    ];
  };
}
