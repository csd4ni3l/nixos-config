{self, ...}: {
  flake.nixosModules.MissionCenter = {
    pkgs,
    lib,
    inputs,
    ...
  }: let
    mkNixPak = import ../../lib/_nixpak.nix {inherit pkgs inputs;};

    mission-center-spawner = pkgs.writeTextFile {
      name = "missioncenter-spawner";
      executable = true;
      destination = "/bin/missioncenter-spawner";
      text = ''
        #!${pkgs.dash}/bin/dash
        while [ "$#" -gt 0 ]; do
          case "$1" in
            -v*)
              shift
              ;;
            --env=*)
              export "''${1#--env=}"
              shift
              ;;
            *)
              break
              ;;
          esac
        done
        if [ "$#" -gt 0 ]; then shift; fi
        exec ${pkgs.mission-center}/bin/missioncenter-magpie "$@"
      '';
    };
  in {
    environment.systemPackages = [
      (mkNixPak {
        config = {sloth, ...}: {
          flatpak.appId = "io.missioncenter.MissionCenter";

          imports = [
            (import ../../modules/_default.nix).module
            (import "${inputs.nixpak}/contrib/modules/gui-base.nix").module
            (import "${inputs.nixpak}/contrib/modules/network.nix").module
          ];

          dbus.policies = {
            "org.freedesktop.Flatpak" = "talk";
            "org.freedesktop.NetworkManager" = "talk";
            "org.freedesktop.systemd1" = "talk";
            "org.gnome.Settings" = "talk";
          };

          bubblewrap = {
            network = lib.mkForce true;
            shareIpc = true;
            sockets = {
              x11 = true;
              pulse = lib.mkForce false;
            };
            bind.ro = [
              "/proc"
              "/sys"
              [ "${mission-center-spawner}/bin" "/app/bin" ]
            ];
            bind.dev = ["/dev/shm"];
          };

          flatpak.info."Instance".app-path = "${pkgs.mission-center}";

          app.package = pkgs.mission-center;
        };
      }).config.env
    ];
  };
}
