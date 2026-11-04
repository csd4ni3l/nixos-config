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

        # NOTE: fixes "No GSettings schemas are installed on the system" when opening the file dialog
        (set-env "GSETTINGS_SCHEMA_DIR" "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas")

        (dbus {
          own = ["org.kde.kdenlive" "org.kde.kdenlive-1" "org.kde.kdenlive-2" "org.kde.kdenlive-3"];
          # NOTE: let Solid list removable devices in the file dialog
          talk = ["org.freedesktop.UDisks2"];
        })
      ]))
    ];
  };
}
