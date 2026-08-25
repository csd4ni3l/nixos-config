{self, ...}: {
  flake.nixosModules.Kdenlive = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (jail.mkSandboxed pkgs.kdePackages.kdenlive "kdenlive" (with jail.combinators; [
        default

        (rw-bind (noescape "~/Videos") (noescape "~/Videos"))
        (dbus { own = [ "org.kde.kdenlive*" ]; })
      ]))
    ];
  };
}
