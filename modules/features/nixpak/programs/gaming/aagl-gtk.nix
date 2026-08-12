{self, ...}: {
  flake.nixosModules.AaglGtk = {
    pkgs,
    inputs,
    lib,
    ...
  }: let
    mkNixPak = import ../../lib/_nixpak.nix {inherit pkgs inputs;};
  in {
    imports = [inputs.aagl.nixosModules.default];
    nix.settings = {
      extra-substituters = ["https://ezkea.cachix.org"];
      extra-trusted-public-keys = ["ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="];
    };
    networking.mihoyo-telemetry.block = true;
    environment.systemPackages = [
      (mkNixPak {
        config = {sloth, ...}: {
          flatpak.appId = "com.nixpak.aagl-gtk";
          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
            (import "${inputs.nixpak}/contrib/modules/network.nix").module
          ];
          app.package = pkgs.anime-game-launcher;

          bubblewrap = {
            bind.dev = ["/dev/ntsync"];
            bind.rw = [
              (sloth.concat' sloth.homeDir "/.local/share/anime-game-launcher")
            ];
          };
        };
      }).config.env
    ];
  };
}
