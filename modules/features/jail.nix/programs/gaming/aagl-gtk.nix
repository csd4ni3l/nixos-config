{self, ...}: {
  flake.nixosModules.AaglGtk = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    imports = [inputs.aagl.nixosModules.default];
    nix.settings = {
      extra-substituters = ["https://ezkea.cachix.org"];
      extra-trusted-public-keys = ["ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="];
    };
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
