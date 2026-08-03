{self, ...}: {
  flake.nixosModules.BrokenFirefox = {
    pkgs,
    inputs,
    ...
  }: let
    mkNixPak = import ../../lib/_nixpak.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (mkNixPak {
        config = {sloth, ...}: {
          flatpak.appId = "org.mozilla.firefox";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
            (import "${inputs.nixpak}/contrib/modules/network.nix").module
            (import "${inputs.nixpak}/contrib/modules/mpris2-player.nix").module
          ];

          app.package = pkgs.firefox;

          bubblewrap = {
            sockets = {
              pipewire = true;
            };

            bind.rw = [
              (sloth.concat' sloth.homeDir "/.config/mozilla")
              (sloth.concat' sloth.homeDir "/Downloads")
            ];
          };
        };
      }).config.env
    ];
  };
}
