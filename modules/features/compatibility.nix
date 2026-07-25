{self, ...}: {
  flake.nixosModules.compatibility = {
    pkgs, inputs, lib, ...
  }: {
    # Automatically creates a loader in /lib/* to avoid patching stuff
    # To disable it temporarily use
    # unset NIX_LD
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # libc / compiler runtime
        stdenv.cc.cc
        zlib
        zstd
        xz
        bzip2
        openssl
        curl
        expat
        libxcrypt

        # Graphics
        libGL
        libGLU
        libdrm
        libgbm
        vulkan-loader
        libva

        # Wayland / X11
        wayland
        libxkbcommon

        xorg.libX11
        xorg.libXext
        xorg.libXrender
        xorg.libXrandr
        xorg.libXcursor
        xorg.libXi
        xorg.libXfixes
        xorg.libXdamage
        xorg.libXcomposite
        xorg.libxcb
        xorg.libxshmfence

        # Audio
        alsa-lib
        pipewire
        libpulseaudio

        # GTK
        glib
        gtk3
        gdk-pixbuf
        cairo
        pango
        atk
        harfbuzz
        fontconfig
        freetype
        librsvg
        webkitgtk_4_1

        # Qt
        icu
        dbus
        krb5
        nspr
        nss

        # USB / udev
        libusb1
        libudev0-shim

        # XML
        libxml2

        # ELF
        libelf

      ];
    };
  };
}
