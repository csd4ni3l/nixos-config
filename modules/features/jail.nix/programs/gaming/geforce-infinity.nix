{self, ...}: {
  flake.nixosModules.GeForceInfinity = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [
      # electron-updater / settings.json (userData before app.setName)
      ".config/geforce-infinity"
      # Chromium session, cache, logs, crashpad (userData after app.setName)
      ".config/GeForce Infinity"
    ];

    environment.systemPackages = [
      (jail.mkSandboxed self.packages.${pkgs.system}."geforce-infinity" "geforce-infinity" (with jail.combinators; [
        default
        network
        keyring-access
        (try-fwd-env "DISPLAY")
        (try-rw-bind "/tmp/.X11-unix" "/tmp/.X11-unix")

        (rw-bind (noescape ''"$HOME/.config/geforce-infinity"'') (noescape ''"$HOME/.config/geforce-infinity"''))
        (rw-bind (noescape ''"$HOME/.config/GeForce Infinity"'') (noescape ''"$HOME/.config/GeForce Infinity"''))
        (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))

        # XKB data
        (try-ro-bind "/run/current-system/sw/share/X11/xkb" "/usr/share/X11/xkb")
        (set-env "XKB_CONFIG_ROOT" (noescape "/run/current-system/sw/share/X11/xkb"))

        # Hardware video decode
        (set-env "LIBVA_DRIVERS_PATH" (noescape "/run/opengl-driver/lib/dri"))
        (set-env "VK_ICD_FILENAMES" (noescape "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"))
        (set-env "VK_DRIVER_FILES" (noescape "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"))

        # Controllers
        (try-ro-bind "/run/udev" "/run/udev")
        (unsafe-add-raw-args "--dev-bind-try /dev/input /dev/input")
        (add-runtime ''
          for DEV in /dev/hidraw*; do
            [ -e "$DEV" ] || continue
            RUNTIME_ARGS+=(--dev-bind-try "$DEV" "$DEV")
          done
        '')

        (dbus {
          own = [
            "net.astralvixen.geforceinfinity"
            "net.astralvixen.geforceinfinity.*"
          ];
          talk = [
            "org.freedesktop.ScreenSaver"
            "org.freedesktop.PowerManagement"
            "org.gnome.SessionManager"
          ];
        })
      ]))
    ];
  };
}
