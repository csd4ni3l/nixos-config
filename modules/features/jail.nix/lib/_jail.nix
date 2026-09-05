{
  pkgs,
  inputs,
}: let
  jailFn = inputs.jail-nix.lib.extend {
    pkgs = pkgs;
    additionalCombinators = c:
      with c; let
        gui-base = compose [
          gui
          gpu
          notifications
          (dbus {
            talk = [
              "org.freedesktop.DBus"
              "org.gtk.vfs"
              "org.gtk.vfs.*"
              "ca.desrt.dconf"
              "org.freedesktop.portal.*"
              "org.a11y.Bus"
            ];
          })
          (rw-bind (noescape "~/.cache") (noescape "~/.cache"))
          (try-ro-bind (noescape "~/.config/gtk-2.0") (noescape "~/.config/gtk-2.0"))
          (try-ro-bind (noescape "~/.config/gtk-3.0") (noescape "~/.config/gtk-3.0"))
          (try-ro-bind (noescape "~/.config/gtk-4.0") (noescape "~/.config/gtk-4.0"))
          (try-ro-bind (noescape "~/.config/fontconfig") (noescape "~/.config/fontconfig"))
          (unsafe-add-raw-args "--bind-try \"$XDG_RUNTIME_DIR/at-spi/bus\" \"$XDG_RUNTIME_DIR/at-spi/bus\"")
          (unsafe-add-raw-args "--bind-try \"$XDG_RUNTIME_DIR/gvfsd\" \"$XDG_RUNTIME_DIR/gvfsd\"")
          (unsafe-add-raw-args "--bind-try \"$XDG_RUNTIME_DIR/dconf\" \"$XDG_RUNTIME_DIR/dconf\"")
          (unsafe-add-raw-args "--bind-try \"$XDG_RUNTIME_DIR/doc\" \"$XDG_RUNTIME_DIR/doc\"")
          (set-env "XDG_DATA_DIRS" "/run/current-system/sw/share:${pkgs.adwaita-icon-theme}/share:${pkgs.shared-mime-info}/share")
          (set-env "XCURSOR_PATH" "${pkgs.adwaita-icon-theme}/share/icons:${pkgs.adwaita-icon-theme}/share/pixmaps")
          (try-fwd-env "QT_QPA_PLATFORM")
          (try-fwd-env "QT_QPA_PLATFORMTHEME")
          (try-fwd-env "QT_STYLE_OVERRIDE")
          (try-fwd-env "GTK_THEME")
          (try-fwd-env "GDK_BACKEND")
        ];
        common-access = compose [
          (ro-bind "/nix/store" "/nix/store")
          (ro-bind "/run/current-system/sw" "/run/current-system/sw")
          (ro-bind "/etc/host.conf" "/etc/host.conf")
          (ro-bind "/etc/gai.conf" "/etc/gai.conf")
          (ro-bind "/etc/os-release" "/etc/os-release")
          (ro-bind "/etc/passwd" "/etc/passwd")
          (ro-bind "/etc/group" "/etc/group")
          (ro-bind "/etc/profiles" "/etc/profiles")
          (ro-bind "/etc/static/profiles" "/etc/static/profiles")
          (ro-bind "/lib64" "/lib64")
          (fwd-env "PATH")
          (try-fwd-env "SHELL")
          (try-fwd-env "USER")
          (try-fwd-env "LOGNAME")
          (try-fwd-env "LOCALE_ARCHIVE")
          (try-fwd-env "LC_ALL")
          (try-fwd-env "LC_CTYPE")
          (try-fwd-env "LC_MESSAGES")
          (try-fwd-env "LC_NUMERIC")
          (try-fwd-env "LC_TIME")
          (try-fwd-env "LC_COLLATE")
          (try-fwd-env "LC_MONETARY")
          (try-fwd-env "LC_PAPER")
          (try-fwd-env "LC_NAME")
          (try-fwd-env "LC_ADDRESS")
          (try-fwd-env "LC_TELEPHONE")
          (try-fwd-env "LC_MEASUREMENT")
          (try-fwd-env "LC_IDENTIFICATION")
        ];
      in {
        inherit gui-base common-access;
        default = compose [
          gui-base
          common-access
          (set-env "COLOR_SCHEME" "prefer-dark")
          (set-env "ELECTRON_OZONE_PLATFORM_HINT" "auto")
          (set-env "XCURSOR_THEME" "Bibata-Modern-Ice")
          (set-env "XCURSOR_SIZE" "24")
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
