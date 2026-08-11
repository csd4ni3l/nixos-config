{self, ...}: {
  flake.nixosModules.FedoraMediaWriter = {
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
          flatpak.appId = "org.fedoraproject.MediaWriter";

          dbus.policies = {
            "org.freedesktop.UDisks2" = "talk";
            "org.freedesktop.Notifications" = "talk";
          };

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
          ];

          app.package = pkgs.mediawriter;

          bubblewrap = {
            sockets = {
              # Doesnt need sound
              pulse = lib.mkForce false;
            };
            bind.ro = [
              (sloth.concat' sloth.homeDir "/Downloads")
            ];
            # NOTE: Instead of giving full /dev access, use the TARGET_USB variable.
            bind.dev = [(sloth.concat' "/dev" (sloth.env "TARGET_USB"))];
          };
        };
      }).config.env
    ];
  };
}
