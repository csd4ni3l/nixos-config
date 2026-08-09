{self, ...}: {
  flake.nixosModules.Mpv = {
    pkgs,
    inputs,
    ...
  }: let
    mkNixPak = import ../../lib/_nixpak.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (mkNixPak {
        config = {sloth, ...}: {
          flatpak.appId = "io.mpv.Mpv";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
            (import "${inputs.nixpak}/contrib/modules/network.nix").module
          ];

          bubblewrap = {
            bind.ro = [
              "/run/media"
              (sloth.concat' sloth.homeDir "/Downloads")
              (sloth.concat' sloth.homeDir "/Music")
              (sloth.concat' sloth.homeDir "/Videos")
            ];
          };

          app.package = pkgs.mpv;
        };
      }).config.env
    ];
  };
}
