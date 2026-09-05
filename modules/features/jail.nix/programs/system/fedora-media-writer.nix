{self, ...}: {
  flake.nixosModules.FedoraMediaWriter = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (jail.mkSandboxed pkgs.mediawriter "mediawriter" (with jail.combinators; [
        default
        (dbus {talk = ["org.freedesktop.UDisks2"];})
        (ro-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        (unsafe-add-raw-args "--dev-bind /dev /dev")
      ]))
    ];
  };
}
