{self, ...}: {
  flake.nixosModules.Ghidra = {
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
          flatpak.appId = "org.ghidra_sre.Ghidra";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
          ];

          bubblewrap = {
            sockets = {
              # Doesnt need sound
              pulse = lib.mkForce false;
              x11 = true;
            };
            # tmpfs on /tmp hides the X11 socket bind, so drop it
            tmpfs = lib.mkForce [];
            bind.rw = [(sloth.concat' sloth.homeDir "/Projects/Programming")];
          };

          app.package = pkgs.ghidra;
        };
      }).config.env
    ];
  };
}
