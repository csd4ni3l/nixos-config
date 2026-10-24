{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  home = config.home.homeDirectory;

  # v1.0.3 + local fixes (see mornye-fixes.patch)
  mornyeSrc = pkgs.applyPatches {
    name = "mornye-1.0.3-fixes";
    src = pkgs.fetchFromGitHub {
      owner = "mornyeapp";
      repo = "Mornye-Python";
      rev = "5660533bf12592e9de68508cef506f173f58d14f";
      hash = "sha256-hEckLZKNwgkJB6AQlrSUGbtN6iQlUZHkzGfM2K8I6HM=";
    };
    patches = [./mornye-fixes.patch];
  };

  # Pinned at Mornye-Extension 6b544663fb5b7a7dfbe1959f3c0edab017378f53.
  tideSflx = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/mornyeapp/Mornye-Extension/6b544663fb5b7a7dfbe1959f3c0edab017378f53/extensions/tidal-web.sflx";
    hash = "sha256-ac5S6r3Z32Rkowt5O4AtPXvjKzMQgsAqm/KyXR1JEU0=";
  };
  deezerSflx = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/mornyeapp/Mornye-Extension/6b544663fb5b7a7dfbe1959f3c0edab017378f53/extensions/deezer.sflx";
    hash = "sha256-OYaBce7hQvId4yOzjC7laQ5EZZSW+OcOAVVFZLRk8pI=";
  };
  qobuzSflx = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/mornyeapp/Mornye-Extension/6b544663fb5b7a7dfbe1959f3c0edab017378f53/extensions/qobuz-web.sflx";
    hash = "sha256-BUwdLEAFi0n1reF6ZEQgFN3wWURmOhLHkKF9Y+6ZmF8=";
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
    FROM docker.io/python:3.12-slim@sha256:a0f57064cbdcd6285fa45f51237ab0b35ea8ebaed06a1f5973e89e19dfb86704

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

    # Mornye 1.0.3's Turnstile solver is written against pydoll 2.x, but it is unpinned.
    # pydoll 3.0 changed stuff around, which makes Mornye not able to find the Turnstile widget.
    RUN python3 -m pip install --no-cache-dir "pydoll-python==2.27.0" .

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
