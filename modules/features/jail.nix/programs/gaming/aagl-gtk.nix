{self, ...}: {
  flake.nixosModules.AaglGtk = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [".local/share/anime-game-launcher"];

    imports = [inputs.aagl.nixosModules.default];
    networking.mihoyo-telemetry.block = true;
    environment.systemPackages = [
      (jail.mkSandboxed pkgs.anime-game-launcher "anime-game-launcher" (with jail.combinators; [
        default
        network

        (rw-bind (noescape "~/.local/share/anime-game-launcher") (noescape "~/.local/share/anime-game-launcher"))

        (dbus {own = ["moe.launcher.an-anime-game-launcher" "moe.launcher.an-anime-game-launcher.*"];})

        (unsafe-add-raw-args "--dev-bind /dev/ntsync /dev/ntsync")
      ]))
    ];
  };
}
