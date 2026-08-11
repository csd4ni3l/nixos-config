{self, ...}: {
  flake.nixosModules.Firefox = {
    pkgs,
    inputs,
    lib,
    config,
    ...
  }: let
    mkNixPak = import ../../lib/_nixpak.nix {inherit pkgs inputs;};
  in {
    environment.systemPackages = [
      (mkNixPak {
        config = {sloth, ...}: {
          flatpak.appId = "org.mozilla.firefox";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
            (import "${inputs.nixpak}/contrib/modules/network.nix").module
          ];

          app.package = pkgs.firefox;

          dbus.policies = {
            "org.mpris.MediaPlayer2.firefox" = "own";
            "org.mpris.MediaPlayer2.firefox.*" = "own";
          };

          bubblewrap = {
            sockets = {
              pulse = lib.mkForce false;
              pipewire = true;
            };

            bind.dev =
              if config.nixcfgs.firefox_full_dev_access then
                ["/dev"]
              else
                # NOTE: Security Key / WebAuthn support when full dev access is disabled
                # Hotplug is not possible because hidraw devices are dynamically generated and bubblewrap can only allow access for devices that exist at its launch
                lib.genList (i: "/dev/hidraw${toString i}") 9;

            # NOTE: needed for Security Key / WebAuthn support
            bind.ro = [
              "/sys/class/hidraw" # only hidraw class
              "/sys/devices/pci0000:00" # full PCI root, we cannot predict where the key will end up
            ];

            bind.rw = [
              (sloth.concat' sloth.homeDir "/.cache/mozilla")
              (sloth.concat' sloth.homeDir "/.config/mozilla")
              (sloth.concat' sloth.homeDir "/Downloads")
              # NOTE: firefox wants to create it's own pulse socket for some reason,
              (sloth.concat' sloth.runtimeDir "/pulse")
            ];
          };
        };
      }).config.env
    ];
  };
}
