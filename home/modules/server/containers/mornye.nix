{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  home = config.home.homeDirectory;

  mornyeSrc = pkgs.fetchFromGitHub {
    owner = "mornyeapp";
    repo = "Mornye-Python";
    rev = "dcff676b234b3a1e4ee4a7ee65443d74a70032d8";
    hash = "sha256-YUV7vD/p3osIu0RIWbOyrF2A8m89TuduzGTVKjN80K8=";
  };

  # Pinned at Mornye-Extension e9d2499688f77d8cbc224c1c1a1fe2ccfdb94555.
  tideSflx = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/mornyeapp/Mornye-Extension/e9d2499688f77d8cbc224c1c1a1fe2ccfdb94555/extensions/tidal-web.sflx";
    hash = "sha256-DyPwNLLzjnLQerzLl06305z0CcVllzXldFOA/+KBYJQ=";
  };
  deezerSflx = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/mornyeapp/Mornye-Extension/e9d2499688f77d8cbc224c1c1a1fe2ccfdb94555/extensions/deezer.sflx";
    hash = "sha256-KYxE134E9bKWCesgaBU/I+QYuQVcRLIZrF25iI4OXDQ=";
  };
  qobuzSflx = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/mornyeapp/Mornye-Extension/e9d2499688f77d8cbc224c1c1a1fe2ccfdb94555/extensions/qobuz-web.sflx";
    hash = "sha256-wpvfn4FuXqq1lWVS9yNr6bGOiSVc4sObdoHSTzWM3pc=";
  };

  # Unpack on build, injecting _registry_sha256 so installed manifests match
  # registry metadata.
  pinnedExtensions =
    pkgs.runCommand "mornye-extensions" {
      nativeBuildInputs = [pkgs.jq pkgs.unzip];
    } ''
      mkdir -p $out
      unpack() {
        id="$1"
        archive="$2"
        sha="$(sha256sum "$archive" | cut -d' ' -f1)"
        mkdir -p "$out/$id"
        unzip -q "$archive" -d "$out/$id"
        jq --arg sha "$sha" '. + {_registry_sha256: $sha}' \
          "$out/$id/manifest.json" > "$out/$id/manifest.json.tmp"
        mv "$out/$id/manifest.json.tmp" "$out/$id/manifest.json"
      }
      unpack tidal-web ${tideSflx}
      unpack deezer ${deezerSflx}
      unpack qobuz-web ${qobuzSflx}
    '';

  # MORNYE_REGISTRIES is unset, so the registry cannot overwrite the pins.
  seedExtensions = pkgs.writeShellScript "mornye-seed-extensions" ''
    set -euo pipefail
    export PATH=${lib.makeBinPath [pkgs.coreutils pkgs.jq]}:$PATH
    target=${lib.escapeShellArg "${home}/containers/mornye/data/extensions"}
    mkdir -p "$target"

    seed() {
      src="$1"
      name="$(basename "$src")"
      version="$(jq -r '.version' "$src/manifest.json")"
      sha="$(jq -r '._registry_sha256 // empty' "$src/manifest.json")"
      dest="$target/$name"

      if [ -f "$dest/manifest.json" ] \
         && [ "$(jq -r '.version' "$dest/manifest.json")" = "$version" ] \
         && [ "$(jq -r '._registry_sha256 // empty' "$dest/manifest.json")" = "$sha" ]; then
        return 0
      fi

      tmp="$target/.$name.tmp"
      rm -rf "$tmp"
      cp -r "$src" "$tmp"
      chmod -R u+rwX "$tmp"
      if [ -f "$dest/settings.json" ]; then
        cp "$dest/settings.json" "$tmp/settings.json"
      fi
      rm -rf "$dest"
      mv "$tmp" "$dest"
    }

    seed ${pinnedExtensions}/tidal-web
    seed ${pinnedExtensions}/deezer
    seed ${pinnedExtensions}/qobuz-web
  '';

  containerfile = pkgs.writeText "mornye-Containerfile" ''
    FROM docker.io/python:3.12-slim@sha256:5e2bdb1b0d542d5039cffb8181c65930093949194a65c365dfb1b0fe13a4fa5b

    ENV PYTHONDONTWRITEBYTECODE=1 \
        PYTHONUNBUFFERED=1 \
        DISPLAY=:99

    # tini/procps for the solver's pkill; Chromium for signed-session
    # handshakes; Xvfb is started on demand by --web.
    RUN apt-get update \
     && apt-get install -y --no-install-recommends \
          tini \
          procps \
          ca-certificates \
          ffmpeg \
          flac \
          nodejs \
          xvfb \
          chromium \
          fonts-liberation \
     && rm -rf /var/lib/apt/lists/*

    WORKDIR /app

    COPY . .

    RUN python3 -m pip install --no-cache-dir .

    ARG APP_UID=1000
    ARG APP_GID=1000
    ENV HOME=/home/mornye

    RUN groupadd --gid "''${APP_GID}" mornye \
     && useradd --uid "''${APP_UID}" --gid "''${APP_GID}" \
          --create-home --home-dir "''${HOME}" mornye \
     && mkdir -p /data /downloads \
                 "''${HOME}/.mornye/extensions" \
                 "''${HOME}/.mornye/signed_sessions" \
     && chown -R mornye:mornye /app /data /downloads "''${HOME}"

    COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
    RUN chmod +x /usr/local/bin/docker-entrypoint.sh

    USER mornye

    ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
    CMD ["--help"]
  '';
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  homelab.containerDirs = [
    "${home}/containers/mornye/data"
    "${home}/containers/mornye/downloads"
  ];

  sops.secrets."mornye-web-token" = {};

  # sops template: the token is substituted after activation.
  sops.templates."mornye-container" = {
    path = "${home}/.config/containers/systemd/mornye.container";
    content = ''
      [Unit]
      Description=mornye
      After=network-online.target

      [Container]
      ContainerName=mornye
      Image=mornye.build
      UserNS=keep-id:uid=1000,gid=1000

      Network=container:openwebui

      Volume=${home}/containers/mornye/data:/data
      Volume=${home}/containers/mornye/downloads:/downloads

      Environment=MORNYE_DATA_DIR=/data
      Environment=MORNYE_CACHE_DIR=/data/.cache
      Environment=MORNYE_DOWNLOAD_DIR=/downloads
      Environment=MORNYE_WEB_TOKEN=${config.sops.placeholder."mornye-web-token"}

      ShmSize=1g

      Exec=--web --host 127.0.0.1 --port 64500

      HealthCmd=python3 -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:64500/healthz', timeout=5)"
      HealthInterval=30s
      HealthTimeout=10s
      HealthRetries=3
      HealthStartPeriod=60s

      [Service]
      ExecStartPre=${seedExtensions}
      Restart=on-failure
      TimeoutStartSec=900

      [Install]
      WantedBy=default.target
    '';
  };

  home.file.".config/containers/systemd/mornye.build".text = ''
    [Unit]
    Description=mornye image build

    [Build]
    ImageTag=localhost/mornye:latest
    File=${containerfile}
    SetWorkingDirectory=${mornyeSrc}

    [Service]
    TimeoutStartSec=900
  '';
}
