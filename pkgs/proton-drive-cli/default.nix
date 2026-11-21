{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeBinaryWrapper,
  libsecret,
  glib,
}: let
  version = "0.9.0";
in
  stdenvNoCC.mkDerivation {
    pname = "proton-drive-cli";
    inherit version;

    src = fetchurl {
      url = "https://proton.me/download/drive/cli/${version}/linux-x64/proton-drive";
      hash = "sha256-T2b5hLY2EITUZWe49P1IUfQnHrn3fl0YHh7/PIozJQE=";
    };

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    # NOTE: Bun single-file executable; stripping would destroy the embedded JS bundle.
    dontStrip = true;

    nativeBuildInputs = [autoPatchelfHook makeBinaryWrapper];

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/libexec/proton-drive
      runHook postInstall
    '';

    # NOTE: Bun.secrets dlopen()s libsecret and GLib at runtime; a RUNPATH would
    # corrupt the Bun executable, so libs are supplied via LD_LIBRARY_PATH instead.
    postFixup = ''
      makeWrapper $out/libexec/proton-drive $out/bin/proton-drive \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [libsecret glib]}
    '';

    meta = {
      description = "Official Proton Drive command-line client";
      homepage = "https://proton.me/download/drive/cli/index.html";
      license = lib.licenses.unfree;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "proton-drive";
    };
  }
