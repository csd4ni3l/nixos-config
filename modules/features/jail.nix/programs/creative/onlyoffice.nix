{self, ...}: {
  flake.nixosModules.OnlyOffice = {
    pkgs,
    inputs,
    ...
  }: let
  jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [ (jail.mkSandboxed pkgs.onlyoffice-desktopeditors "onlyoffice-desktopeditors"
      (with jail.combinators; [
        default
        unsafe-x11
        (rw-bind (noescape "~/.local/share/onlyoffice") (noescape "~/.local/share/onlyoffice"))
        (rw-bind (noescape "~/.config/onlyoffice") (noescape "~/.config/onlyoffice"))
        (rw-bind (noescape "~/Documents") (noescape "~/Documents"))
        (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
      ]))
    ];
  };
}
