{self, ...}: {
  flake.nixosModules.OrcaSlicer = {
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
          flatpak.appId = "com.orcaslicer.OrcaSlicer";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
            (import "${inputs.nixpak}/contrib/modules/network.nix").module
          ];

          app.package = pkgs.orca-slicer;

          bubblewrap = {
            sockets = {
              # Doesnt need sound
              pulse = lib.mkForce false;
            };
            bind.rw = [
              (sloth.concat' sloth.homeDir "/.config/OrcaSlicer") # NOTE: needed so i can change to legacy plugin, which works. The new plugin does not with nix-ld.
              (sloth.concat' sloth.homeDir "/Projects/3D")
            ];
          };
        };
      }).config.env
    ];
  };
}
