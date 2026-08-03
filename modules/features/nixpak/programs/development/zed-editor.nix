{self, ...}: {
  flake.nixosModules.ZedEditor = {
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
          flatpak.appId = "dev.zed.Zed";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
            (import "${inputs.nixpak}/contrib/modules/network.nix").module
          ];

          bubblewrap = {
            sockets = {
              # Doesnt need sound
              pulse = lib.mkForce false;
            };
            bind.rw = [sloth.homeDir];
          };

          app.package = pkgs.symlinkJoin {
            name = "zeditor";
            paths = [
              (pkgs.writeShellScriptBin "zeditor" ''
                exec ${pkgs.zed-editor}/bin/zeditor --foreground "$@"
              '')
              pkgs.zed-editor
            ];
            meta.mainProgram = "zeditor";
          };
        };
      }).config.env
    ];
  };
}
