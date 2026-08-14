{self, ...}: {
  flake.nixosModules.AnyType = {
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
          flatpak.appId = "com.anytype.AnyType";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
            (import "${inputs.nixpak}/contrib/modules/network.nix").module
          ];

          app.package = pkgs.anytype;

          bubblewrap = {
            sockets = {
              # Doesnt need sound
              pulse = lib.mkForce false;
            };
            bind.rw = [
              (sloth.concat' sloth.homeDir "/.config/anytype")
            ];
          };
        };
      }).config.env
    ];
  };
}
