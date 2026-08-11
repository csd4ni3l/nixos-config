{self, ...}: {
  flake.nixosModules.OnlyOffice = {
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
          flatpak.appId = "org.onlyoffice.desktopeditors";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
          ];

          app.package = pkgs.onlyoffice-desktopeditors;

          bubblewrap = {
            sockets = {
              # Doesnt need sound
              pulse = lib.mkForce false;
              x11 = true;
            };
            # NOTE: tmpfs on /tmp hides the X11 socket bind, so drop it
            tmpfs = lib.mkForce [];
            env = {
              QT_QPA_PLATFORM = "wayland";
            };
            bind.rw = [
              (sloth.concat' sloth.homeDir "/.local/share/onlyoffice")
              (sloth.concat' sloth.homeDir "/.config/onlyoffice")
              (sloth.concat' sloth.homeDir "/Documents")
              (sloth.concat' sloth.homeDir "/Downloads")
            ];
          };
        };
      }).config.env
    ];
  };
}
