{self, ...}: {
  flake.nixosModules.Kdenlive = {
    pkgs,
    inputs,
    ...
  }: let
    mkNixPak = import ../../lib/_nixpak.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (mkNixPak {
        config = {sloth, ...}: {
          flatpak.appId = "org.kde.kdenlive";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
          ];

          bubblewrap = {
            sockets = {
              pipewire = true;
            };

            bind.rw = [(sloth.concat' sloth.homeDir "/Videos")];
          };

          app.package = pkgs.kdePackages.kdenlive;
        };
      }).config.env
    ];
  };
}
