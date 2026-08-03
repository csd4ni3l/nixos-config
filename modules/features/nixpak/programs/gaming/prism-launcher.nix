{self, ...}: {
  flake.nixosModules.PrismLauncher = {
    pkgs,
    inputs,
    ...
  }: let
    mkNixPak = import ../../lib/_nixpak.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (mkNixPak {
        config = {sloth, ...}: {
          flatpak.appId = "org.prismlauncher.PrismLauncher";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
            (import "${inputs.nixpak}/contrib/modules/network.nix").module
          ];

          bubblewrap = {
            bind.rw = [(sloth.concat' sloth.homeDir "/.local/share/PrismLauncher")];
          };

          app.package = pkgs.prismlauncher;
        };
      }).config.env
    ];
  };
}
