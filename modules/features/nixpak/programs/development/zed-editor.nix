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
            bind.rw = [
              # NOTE: intentionally broad as it is an editor. Still much better than sloth.homeDir by itself, as that grants .config, .ssh and more.
              (sloth.concat' sloth.homeDir "/Projects")
              (sloth.concat' sloth.homeDir "/Documents")
              (sloth.concat' sloth.homeDir "/Downloads")
              (sloth.concat' sloth.homeDir "/.config/git")
              (sloth.concat' sloth.homeDir "/.config/zed")
              (sloth.concat' sloth.homeDir "/.config/zsh") # NOTE: without this zsh has no cfg
              (sloth.concat' sloth.homeDir "/.local/share/zed")
              (sloth.concat' sloth.homeDir "/.wakatime")
              (sloth.concat' sloth.homeDir "/.wakatime.cfg")
            ];
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
