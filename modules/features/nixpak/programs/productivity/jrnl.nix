{self, ...}: {
  flake.nixosModules.Jrnl = {
    pkgs,
    inputs,
    ...
  }: let
    mkNixPak = import ../../lib/_nixpak.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (mkNixPak {
        config = {sloth, ...}: {
          flatpak.appId = "com.nixpak.jrnl";

          imports = [
            (import ../../modules/_default.nix).module
          ];

          bubblewrap = {
            bind.rw = [(sloth.concat' sloth.homeDir "/.local/share/jrnl")];
            bind.ro = [(sloth.concat' sloth.homeDir "/.config/jrnl/jrnl.yaml")];
          };

          app.package = pkgs.jrnl;
        };
      }).config.env
    ];
  };
}
