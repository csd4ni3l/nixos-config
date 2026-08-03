{self, ...}: {
  flake.nixosModules.MoneroGui = {
    pkgs,
    lib,
    inputs,
    ...
  }: let
    mkNixPak = import ../../lib/_nixpak.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (mkNixPak {
        config = {sloth, ...}: {
          flatpak.appId = "org.getmonero.Monero";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
            # NOTE: network needed because of remote nodes
            (import "${inputs.nixpak}/contrib/modules/network.nix").module
          ];

          bubblewrap = {
            sockets = {
              # Doesnt need sound
              pulse = lib.mkForce false;
            };
            bind.rw = [
              (sloth.concat' sloth.homeDir "/.bitmonero")
              (sloth.concat' sloth.homeDir "/.p2pool")
              (sloth.concat' sloth.homeDir "/Documents/Monero")
            ];
          };

          app.package = pkgs.monero-gui;
        };
      }).config.env
    ];
  };
}
