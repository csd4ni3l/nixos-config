{self, ...}: {
  flake.nixosModules.Firefox = {
    pkgs,
    inputs,
    lib,
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
          ];

          app.package = pkgs.firefox;

          dbus.policies = {
            "org.mpris.MediaPlayer2.firefox" = "own";
            "org.mpris.MediaPlayer2.firefox.*" = "own";
          };

          bubblewrap = {
            sockets = {
              pulse = lib.mkForce false;
              pipewire = true;
            };

            bind.rw = [
              (sloth.concat' sloth.homeDir "/.cache/mozilla")
              (sloth.concat' sloth.homeDir "/.config/mozilla")
              (sloth.concat' sloth.homeDir "/Downloads")
              # NOTE: firefox wants to create it's own pulse socket for some reason,
              (sloth.concat' sloth.runtimeDir "/pulse")
            ];
          };
        };
      }).config.env
    ];
  };
}
