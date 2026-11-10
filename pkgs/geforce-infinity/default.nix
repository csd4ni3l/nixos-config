{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libGL,
  libgbm,
  libX11,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libxkbcommon,
  libXrandr,
  libXrender,
  libXScrnSaver,
  libXt,
  libXtst,
  libxcb,
  libuuid,
  libxml2,
  nspr,
  nss,
  pango,
  pipewire,
  systemd,
  wayland,
  vulkan-loader,
  libpulseaudio,
  libkrb5,
  xdg-utils,
  libsecret,
  libnotify,
  libva,
  hunspell,
  libfido2,
  xkeyboard-config,
}: let
  pname = "geforce-infinity";
  version = "1.2.2";

  runtimeLibs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libGL
    libgbm
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libxkbcommon
    libXrandr
    libXrender
    libXScrnSaver
    libXt
    libXtst
    libxcb
    libuuid
    libxml2
    nspr
    nss
    pango
    pipewire
    systemd
    wayland
    vulkan-loader
    libpulseaudio
    libkrb5
    libsecret
    libnotify
    libva
    hunspell
    libfido2
    stdenv.cc.cc.lib
  ];
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/AstralVixen/GeForce-Infinity/releases/download/${version}/GeForceInfinity-linux-${version}-amd64.deb";
      hash = "sha256-e+SJFoJbZgrQYpL+RFmgAEqFfm35aMI7tWpzaUrY2t4=";
    };

    nativeBuildInputs = [dpkg autoPatchelfHook makeWrapper];

    buildInputs = runtimeLibs;

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x $src .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/opt/GeForceInfinity"
      cp -r opt/GeForceInfinity/. "$out/opt/GeForceInfinity/"
      cp -r usr/share/. "$out/share/"

      substituteInPlace "$out/share/applications/geforce-infinity.desktop" \
        --replace-fail "/opt/GeForceInfinity/geforce-infinity" "/run/current-system/sw/bin/geforce-infinity" \
        --replace-fail "entry=[object Object]" ""

      mkdir -p "$out/bin"
      makeWrapper "$out/opt/GeForceInfinity/geforce-infinity" "$out/bin/geforce-infinity" \
        --prefix LD_LIBRARY_PATH : "$out/opt/GeForceInfinity:${lib.makeLibraryPath runtimeLibs}" \
        --prefix PATH : ${lib.makeBinPath [xdg-utils]} \
        --set XKB_CONFIG_ROOT "${xkeyboard-config}/share/X11/xkb" \
        --add-flags "--no-sandbox"

      runHook postInstall
    '';

    meta = {
      description = "Unofficial GeForce NOW desktop client";
      homepage = "https://github.com/AstralVixen/GeForce-Infinity";
      license = lib.licenses.mit;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      mainProgram = "geforce-infinity";
      platforms = ["x86_64-linux"];
    };
  }
