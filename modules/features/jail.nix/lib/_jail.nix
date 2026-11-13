{
  pkgs,
  inputs,
}: let
  jailFn = inputs.jail-nix.lib.extend {
    pkgs = pkgs;
    additionalCombinators = c:
      with c; let
        # NOTE: parameterized on dbus permissions so default-unsafe-dbus can reuse the rest.
        gui-base-with-dbus = dbusPermissions:
          compose [
            gui
            gpu
            dbusPermissions
            (tmpfs (noescape "~/.cache"))
            (try-ro-bind (noescape "~/.config/gtk-2.0") (noescape "~/.config/gtk-2.0"))
            (try-ro-bind (noescape "~/.config/gtk-3.0") (noescape "~/.config/gtk-3.0"))
            (try-ro-bind (noescape "~/.config/gtk-4.0") (noescape "~/.config/gtk-4.0"))
            (try-ro-bind (noescape "~/.config/fontconfig") (noescape "~/.config/fontconfig"))
            (unsafe-add-raw-args "--bind-try \"$XDG_RUNTIME_DIR/dconf\" \"$XDG_RUNTIME_DIR/dconf\"")
            (unsafe-add-raw-args "--bind-try \"$XDG_RUNTIME_DIR/doc\" \"$XDG_RUNTIME_DIR/doc\"")
            (set-env "XDG_CONFIG_HOME" (noescape "~/.config"))
            (set-env "XDG_DATA_DIRS" "/run/current-system/sw/share:${pkgs.adwaita-icon-theme}/share:${pkgs.shared-mime-info}/share")
            (set-env "XCURSOR_PATH" "${pkgs.adwaita-icon-theme}/share/icons:${pkgs.adwaita-icon-theme}/share/pixmaps")
            (try-fwd-env "QT_QPA_PLATFORM")
            (try-fwd-env "QT_QPA_PLATFORMTHEME")
            (try-fwd-env "QT_STYLE_OVERRIDE")
            (try-fwd-env "GTK_THEME")
            (try-fwd-env "GDK_BACKEND")
          ];

        # NOTE: dbus permissions used by the regular, filtered gui-base.
        filtered-dbus = compose [
          notifications
          (dbus {
            talk = [
              "org.freedesktop.DBus"
              "org.gtk.vfs"
              "org.gtk.vfs.*"
              "ca.desrt.dconf"
              "org.freedesktop.portal.*"
              "org.a11y.Bus"
              "org.kde.StatusNotifierWatcher"
              "org.freedesktop.StatusNotifierWatcher"
            ];
          })
        ];

        gui-base = gui-base-with-dbus filtered-dbus;

        common-access = compose [
          (ro-bind "/nix/store" "/nix/store")
          (ro-bind "/run/current-system/sw" "/run/current-system/sw")
          (ro-bind "/etc/os-release" "/etc/os-release")
          (ro-bind "/etc/profiles" "/etc/profiles")
          (ro-bind "/etc/static/profiles" "/etc/static/profiles")
          (ro-bind "/lib64" "/lib64")
          (fwd-env "PATH")
          (try-fwd-env "SHELL")
          (try-fwd-env "USER")
          (try-fwd-env "LOGNAME")
          (try-fwd-env "LOCALE_ARCHIVE")
          (try-fwd-env "LANG")
        ];
        default-with-dbus = dbusPermissions:
          compose [
            (gui-base-with-dbus dbusPermissions)
            common-access
            (set-env "COLOR_SCHEME" "prefer-dark")
            (set-env "ELECTRON_OZONE_PLATFORM_HINT" "auto")
            (set-env "XCURSOR_THEME" "Bibata-Modern-Ice")
            (set-env "XCURSOR_SIZE" "24")
          ];
      in {
        inherit gui-base common-access;
        gui-base-unsafe-dbus = gui-base-with-dbus unsafe-dbus;
        default = default-with-dbus filtered-dbus;

        # NOTE: uses the real session bus because xdg-dbus-proxy drops unicast signals (e.g. Steam's pressure-vessel launcher).
        default-unsafe-dbus = default-with-dbus unsafe-dbus;
        keyring-access = compose [
          (dbus {
            talk = ["org.freedesktop.secrets" "org.kde.kwalletd6"];
          })
        ];
      };
  };

  mkSandboxed = pkg: name: permissions: let
    jailed = jailFn name pkg permissions;
  in
    pkgs.runCommand "${name}-sandboxed" {} ''
      cp -rs "${pkg}" "$out"
      if [ -L "$out/bin" ]; then
        mv "$out/bin" "$out/bin.tmp"
        mkdir -p "$out/bin"
        shopt -s nullglob
        for f in "$out/bin.tmp"/*; do
          ln -s "$f" "$out/bin/$(basename "$f")"
        done
        shopt -u nullglob
        rm -rf "$out/bin.tmp"
      else
        chmod u+w "$out/bin"
      fi
      rm -f "$out/bin/${name}"
      ln -s "${jailed}/bin/${name}" "$out/bin/${name}"
    '';
in
  jailFn // {inherit mkSandboxed;}
