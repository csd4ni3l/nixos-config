{
  stdenv,
  fetchurl,
  lib,
  autoPatchelfHook,
}: let
  version = "1.0.0-rc.3";
in
  stdenv.mkDerivation {
    pname = "pelican-wings";
    inherit version;

    src = fetchurl {
      url = "https://github.com/pelican/wings/releases/download/v${version}/wings_linux_amd64";
      hash = "sha256-NtYtQdYRLpzIVeD3X9bNB8PlQTY8Xdt030jCl6Gvi/Q=";
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
