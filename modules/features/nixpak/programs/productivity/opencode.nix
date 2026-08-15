{self, ...}: {
  flake.nixosModules.OpenCode = {
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
          flatpak.appId = "ai.opencode.opencode";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/network.nix").module
          ];

          bubblewrap = {
            sockets = {
              # Doesnt need sound
              pulse = lib.mkForce false;
            };
            bind.rw = [
              (sloth.concat' sloth.homeDir "/.config/opencode")
              (sloth.concat' sloth.homeDir "/.local/share/opencode")
              (sloth.concat' sloth.homeDir "/.local/state/opencode")
              (sloth.env "PWD")
            ];
          };

          app.package = pkgs.opencode;
        };
      }).config.env
    ];
  };
}
