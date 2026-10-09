{self, ...}: {
  flake.nixosModules.ProtonPlus = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [".local/share/Steam" ".steam"];

    environment.systemPackages = [
      (jail.mkSandboxed pkgs.protonplus "protonplus" (with jail.combinators; [
        default
        network

        (rw-bind (noescape "~/.local/share/Steam") (noescape "~/.local/share/Steam"))
        (dbus {own = ["com.vysp3r.ProtonPlus" "com.vysp3r.ProtonPlus.*"];})
        (rw-bind (noescape "~/.steam") (noescape "~/.steam"))
      ]))
    ];
  };
}
