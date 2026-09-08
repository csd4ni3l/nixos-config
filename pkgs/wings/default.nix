{
  stdenv,
  fetchurl,
  lib,
  autoPatchelfHook,
}: let
  version = "1.0.0-beta29";
in
  stdenv.mkDerivation {
    pname = "pelican-wings";
    inherit version;

    src = fetchurl {
      url = "https://github.com/pelican/wings/releases/download/v${version}/wings_linux_amd64";
      hash = "sha256-ddgezyU2btPAWtbGzLrVMu2Ja4IZqp0sk6WvAD1pAAs=";
    };

    nativeBuildInputs = [autoPatchelfHook];

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      mkdir -p $out
      cp $src $out/wings
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 $out/wings $out/bin/wings
      rm $out/wings
      runHook postInstall
    '';

    postFixup = ''
      autoPatchelf $out/bin/wings
    '';

    meta = {
      description = "Pelican Wings - server control plane daemon for the Pelican Panel";
      homepage = "https://github.com/pelican/wings";
      license = lib.licenses.mit;
      mainProgram = "wings";
      platforms = lib.platforms.linux;
    };
  }
