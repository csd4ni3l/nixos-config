{self, ...}: {
  flake.nixosModules.ObsStudio = {
    pkgs,
    inputs,
    ...
  }: let
    mkNixPak = import ../../lib/_nixpak.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (mkNixPak {
        config = {sloth, ...}: {
          flatpak.appId = "com.obsproject.Studio";

          dbus.policies = {
            "org.freedesktop.Notifications" = "talk";
          };

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
          ];

          bubblewrap = {
            sockets = {
              pipewire = true;
            };
            bind.rw = [(sloth.concat' sloth.homeDir "/Videos/OBS")];
          };

          app.package = pkgs.obs-studio;
        };
      }).config.env
    ];
  };
}
