{self, ...}: {
  flake.nixosModules.Audacity = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [".config/audacity" ".local/share/audacity"];

    environment.systemPackages = [
      (jail.mkSandboxed pkgs.audacity "audacity" (with jail.combinators; [
        default

        (ro-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        (rw-bind (noescape "~/Documents/Audacity4") (noescape "~/Documents/Audacity4"))
        (rw-bind (noescape "~/Music") (noescape "~/Music"))
        (ro-bind (noescape "~/Videos") (noescape "~/Videos"))

        (rw-bind (noescape "~/.config/audacity") (noescape "~/.config/audacity"))
        (rw-bind (noescape "~/.local/share/audacity") (noescape "~/.local/share/audacity"))

        # NOTE: Audacity 4 overrides QT_QPA_PLATFORM itself
        (set-env "AU_QT_QPA_PLATFORM" "wayland")
        (set-env "QT_QPA_PLATFORM" "wayland")

        # NOTE: fixes GSettings errors from the GTK integration / file dialog
        (set-env "GSETTINGS_SCHEMA_DIR" "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas")
      ]))
    ];
  };
}
