{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  dbus,
  fontconfig,
  freetype,
  glib,
  libdrm,
  libglvnd,
  libpulseaudio,
  libx11,
  libxcb,
  libxext,
  libxfixes,
  libxrandr,
  libxrender,
  libxkbcommon,
  mesa,
  vulkan-loader,
  wayland,
  xcbutil,
  xcbutilcursor,
  xcbutilimage,
  xcbutilkeysyms,
  xcbutilrenderutil,
  xcbutilwm,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ladybird";
  version = "2026.47.7";

  src = fetchurl {
    url = "https://apt.ladybird.org/pool/main/l/ladybird/ladybird_${finalAttrs.version}-1~ubuntu24.04_amd64.deb";
    hash = "sha256-Z+M/CiNLZyc0uJZep91cY8jwthYxO5HUNSLFOtaGsdQ=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    dbus
    fontconfig
    freetype
    glib
    libdrm
    libglvnd
    libpulseaudio
    libx11
    libxcb
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    libxrender
    vulkan-loader
    wayland
    xcbutil
    xcbutilcursor
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
    zlib
  ];

  runtimeLibs = [
    dbus
    fontconfig
    freetype
    glib
    libdrm
    libglvnd
    libpulseaudio
    libx11
    libxcb
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    libxrender
    mesa
    vulkan-loader
    wayland
    xcbutil
    xcbutilcursor
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
  ];

  # NOTE: neither library ships with the bundle or exists in nixpkgs; the linker
  # records them but they are only probed lazily at runtime.
  autoPatchelfIgnoreMissingDeps = ["libGLES_CM.so.1" "libsteam_api.so"];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile "$src" | tar -x --no-same-owner
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a opt/ladybird "$out/ladybird"

    # NOTE: the profile path is the sandboxed wrapper, so launcher and D-Bus
    # activation start the jail instead of the unwrapped store binary.
    install -Dm644 usr/share/applications/org.ladybird.Ladybird.desktop \
      "$out/share/applications/org.ladybird.Ladybird.desktop"
    substituteInPlace "$out/share/applications/org.ladybird.Ladybird.desktop" \
      --replace-fail "/opt/ladybird/bin/Ladybird" "/run/current-system/sw/bin/ladybird"

    install -Dm644 usr/share/dbus-1/services/org.ladybird.Ladybird.service \
      "$out/share/dbus-1/services/org.ladybird.Ladybird.service"
    substituteInPlace "$out/share/dbus-1/services/org.ladybird.Ladybird.service" \
      --replace-fail "/opt/ladybird/bin/Ladybird" "/run/current-system/sw/bin/ladybird"

    install -Dm644 usr/share/icons/hicolor/scalable/apps/org.ladybird.Ladybird.svg \
      "$out/share/icons/hicolor/scalable/apps/org.ladybird.Ladybird.svg"
    install -Dm644 usr/share/metainfo/org.ladybird.Ladybird.metainfo.xml \
      "$out/share/metainfo/org.ladybird.Ladybird.metainfo.xml"

    runHook postInstall
  '';

  postInstall = ''
    makeWrapper "$out/ladybird/bin/Ladybird" "$out/bin/ladybird" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.runtimeLibs}" \
      --set QT_PLUGIN_PATH "$out/ladybird/Qt6/plugins"
  '';

  meta = {
    description = "Truly independent web browser, repackaged from the Ubuntu noble .deb";
    homepage = "https://ladybird.org";
    license = lib.licenses.bsd2;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = ["x86_64-linux"];
    mainProgram = "ladybird";
  };
})
