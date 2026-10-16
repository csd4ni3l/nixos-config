{self, ...}: {
  flake.nixosModules.Steam = {
    pkgs,
    inputs,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};
  in {
    nixcfgs.jail_dirs = [
      ".local/share/Steam"
      ".steam"
      ".cache/mesa_shader_cache"
      ".cache/mesa_shader_cache_db"
      ".cache/radv_builtin_shaders"
      ".cache/radv_builtin_shaders64"
    ];

    hardware.steam-hardware.enable = true;

    environment.systemPackages = [
      (jail.mkSandboxed pkgs.steam "steam"
        (with jail.combinators; [
          default
          network
          unsafe-x11

          (ro-bind "/sys" "/sys")

          (try-ro-bind "/run/udev" "/run/udev")

          (try-ro-bind "/etc/asound.conf" "/etc/asound.conf")
          (try-ro-bind "/etc/alsa" "/etc/alsa")
          (try-ro-bind "/etc/pulse" "/etc/pulse")
          (try-ro-bind "/etc/pipewire" "/etc/pipewire")

          (rw-bind (noescape "~/.local/share/Steam") (noescape "~/.local/share/Steam"))
          (rw-bind (noescape "~/.steam") (noescape "~/.steam"))
          (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
          (try-rw-bind (noescape "/run/media") (noescape "/run/media"))

          (rw-bind (noescape "~/.cache/mesa_shader_cache") (noescape "~/.cache/mesa_shader_cache"))
          (rw-bind (noescape "~/.cache/mesa_shader_cache_db") (noescape "~/.cache/mesa_shader_cache_db"))
          (rw-bind (noescape "~/.cache/radv_builtin_shaders") (noescape "~/.cache/radv_builtin_shaders"))
          (rw-bind (noescape "~/.cache/radv_builtin_shaders64") (noescape "~/.cache/radv_builtin_shaders64"))

          (dbus {
            own = ["com.steampowered.*"];
            talk = [
              "org.gnome.SettingsDaemon.MediaKeys"
              "org.kde.StatusNotifierWatcher"
              "org.freedesktop.ScreenSaver"
              "org.freedesktop.PowerManagement"
            ];
          })

          (unsafe-add-raw-args "--dev-bind-try /dev/input /dev/input")
          (unsafe-add-raw-args "--dev-bind-try /dev/uinput /dev/uinput")
          (unsafe-add-raw-args "--dev-bind-try /dev/ntsync /dev/ntsync")
          (unsafe-add-raw-args "--dev-bind-try /dev/snd /dev/snd")
          (add-runtime ''
            for DEV in /dev/hidraw*; do
              [ -e "$DEV" ] || continue
              RUNTIME_ARGS+=(--dev-bind-try "$DEV" "$DEV")
            done
          '')
        ]))
    ];
  };
}
