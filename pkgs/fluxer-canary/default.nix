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
  hunspell,
  libfido2,
}: let
  pname = "fluxer-canary";
  version = "2026.1009.45608";

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
    hunspell
    libfido2
    stdenv.cc.cc
  ];
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://pkgs.fluxer.com/desktop/canary/linux/x64/${version}/deb";
      hash = "sha256-+CZupjV0WxM5WbkB8p9shpbKLtoB8AslelNXzDu0F9Q=";
    };

    nativeBuildInputs = [dpkg autoPatchelfHook makeWrapper];

    autoPatchelfIgnoreMissingDeps = ["libc.musl-*.so.*"];

    buildInputs = runtimeLibs;

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x $src .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/opt/${pname}"
      cp -r "opt/${pname}"/. "$out/opt/${pname}/"
      cp -r usr/share/. $out/share/

      substituteInPlace "$out/opt/${pname}/${pname}-launcher" \
        --replace-fail "/opt/${pname}/${pname}" "$out/bin/${pname}"

      substituteInPlace "$out/share/applications/app.fluxer.FluxerDesktopCanary.desktop" \
        --replace-fail "/opt/${pname}/${pname}-launcher" "/run/current-system/sw/bin/${pname}" \
        --replace-fail '"/opt/${pname}/${pname}"' "/run/current-system/sw/bin/${pname}"

      mkdir -p $out/bin
      makeWrapper "$out/opt/${pname}/${pname}" "$out/bin/${pname}" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
        --prefix PATH : ${lib.makeBinPath [xdg-utils]}

      runHook postInstall
    '';

    meta = {
      description = "Fluxer Canary - Free and open source instant messaging and VoIP platform (canary channel)";
      homepage = "https://fluxer.app";
      license = lib.licenses.agpl3Plus;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      mainProgram = pname;
      platforms = ["x86_64-linux"];
    };
  }
