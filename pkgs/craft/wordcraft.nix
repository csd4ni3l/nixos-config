{
  makeWrapper,
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  fontconfig,
  freetype,
  glib,
  libGL,
  libdrm,
  libxkbcommon,
  vulkan-loader,
  wayland,
  libx11,
  libXcursor,
  libXi,
  libXrandr,
  libxcb,
}: let
  pname = "wordcraft";
  version = "0.6.1";

  arch = "x86_64";
  hash = "sha256:1y9qrajxgbwfwg7dx0aqrfsal3jyq7g2lhr229aymxkn2b459gbr";

  runtimeLibs = [
    alsa-lib
    fontconfig
    freetype
    glib
    libGL
    libdrm
    libxkbcommon
    stdenv.cc.cc
    vulkan-loader
    wayland
    libx11
    libXcursor
    libXi
    libXrandr
    libxcb
  ];
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/storytold/${pname}/releases/download/v${version}/${pname}-${version}-linux-${arch}.tar.gz";
      inherit hash;
    };

    sourceRoot = "${pname}-${version}-linux-${arch}";

    nativeBuildInputs = [makeWrapper];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/libexec/${pname}" "$out/bin"
      cp -r share "$out/share"
      install -Dm755 "bin/${pname}" "$out/libexec/${pname}/${pname}"

      makeWrapper "$out/libexec/${pname}/${pname}" "$out/bin/${pname}" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}

      runHook postInstall
    '';

    meta = {
      description = "${pname} - part of the ArtCraft Craft App Suite, pure Rust";
      homepage = "https://github.com/storytold/${pname}";
      license = lib.licenses.asl20;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      mainProgram = pname;
      platforms = ["x86_64-linux"];
    };
  }
