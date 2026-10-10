{
  config,
  pkgs,
  inputs,
  ...
}: let
  home = config.home.homeDirectory;

  ntfyTopics = "mcp";

  slskSrc = pkgs.applyPatches {
    name = "slsk-mcp-src";
    src = pkgs.fetchFromGitHub {
      owner = "voidtype";
      repo = "slsk_mcp";
      rev = "df06ca17e2931246b1f139abf028a22e808da7a3";
      hash = "sha256-fnBXTmAvGec6WPrjrj/tGF1Na99RM3VuRdVpls3lHgg=";
    };
    patches = [./slsk-dest-dir.patch];
  };

  containerfile = pkgs.writeText "mcp-gateway-Containerfile" ''
    FROM ghcr.io/mikkoparkkola/mcp-gateway:3.5.1@sha256:96b8e1ae09941bf0bc2ed07d2e94f3d5cfd73861b720a5b1c7629f560dd3232c

    USER root

    RUN apt-get update \
     && apt-get install -y --no-install-recommends ca-certificates curl gnupg git \
     && curl -fsSL https://deb.nodesource.com/setup_24.x -o /tmp/nodesource.sh \
     && bash /tmp/nodesource.sh \
     && apt-get install -y --no-install-recommends nodejs \
     && rm -f /tmp/nodesource.sh \
     && rm -rf /var/lib/apt/lists/* \
     && node --version | grep -q '^v24\.'

    RUN curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh \
     && env UV_INSTALL_DIR=/usr/local/bin UV_NO_MODIFY_PATH=1 sh /tmp/uv-install.sh \
     && rm -f /tmp/uv-install.sh

    RUN npm install -g --no-fund --no-audit \
          navidrome-mcp@2.6.0 \
          @ni-c/freshrss-mcp@0.3.2 \
          @ni-c/ntfy-mcp@0.3.0 \
          open-meteo-mcp-server@2.5.2 \
          mcp-lrclib@2.0.1 \
          musicbrainz-mcp@1.2.6 \
          @safedep/vet@1.20.0 \
          patchright-mcp@0.0.68

    RUN npx -y patchright@1.58.2 install --with-deps chrome \
     && rm -rf /root/.npm /var/lib/apt/lists/*

    ENV UV_CACHE_DIR=/opt/uv/cache
    ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
    ENV UV_PROJECT_ENVIRONMENT=/opt/slsk-venv

    WORKDIR /build/slsk
    COPY pyproject.toml uv.lock ./
    RUN uv sync --frozen --no-dev --no-install-project
    COPY . .
    RUN uv sync --frozen --no-dev \
     && chmod -R a+rX /opt/slsk-venv /opt/uv

    RUN mkdir -p /home/gateway/.local /home/gateway/.cache \
     && chown -R gateway:gateway /home/gateway /opt/uv/cache
    USER gateway
    ENV HOME=/home/gateway
    ENV UV_TOOL_BIN_DIR=/home/gateway/.local/bin
    RUN uv tool install mcp-nixos==3.1.0
  '';
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  homelab.containerDirs = ["${config.home.homeDirectory}/containers/playwright-mcp"];

  sops.secrets."navidrome-mcp-navidrome-url" = {};
  sops.secrets."navidrome-mcp-navidrome-username" = {};
  sops.secrets."navidrome-mcp-navidrome-password" = {};
  sops.secrets."slsk-mcp-username" = {};
  sops.secrets."slsk-mcp-password" = {};
  sops.secrets."mcp-gateway-token" = {};
  sops.secrets."freshrss-mcp-url" = {};
  sops.secrets."freshrss-mcp-user" = {};
  sops.secrets."freshrss-mcp-api-password" = {};
  sops.secrets."ntfy-mcp-url" = {};

  sops.templates."mcp-gateway-config".content = ''
    server:
      host: 127.0.0.1
      port: 39400
    auth:
      enabled: true
      bearer_token: "${config.sops.placeholder."mcp-gateway-token"}"
      public_paths:
        - /health
    meta_mcp:
      enabled: true
    backends:
      navidrome:
        description: "Navidrome music library and radio station management"
        command: navidrome-mcp
        env:
          NAVIDROME_URL: "${config.sops.placeholder."navidrome-mcp-navidrome-url"}"
          NAVIDROME_USERNAME: "${config.sops.placeholder."navidrome-mcp-navidrome-username"}"
          NAVIDROME_PASSWORD: "${config.sops.placeholder."navidrome-mcp-navidrome-password"}"
      slsk:
        description: "Soulseek file search and download"
        command: /opt/slsk-venv/bin/slsk-mcp
        cwd: /home/gateway
        env:
          SLSK_USERNAME: "${config.sops.placeholder."slsk-mcp-username"}"
          SLSK_PASSWORD: "${config.sops.placeholder."slsk-mcp-password"}"
          SLSK_DOWNLOAD_DIR: /music
      freshrss:
        description: "FreshRSS feed reader"
        command: freshrss-mcp
        env:
          FRESHRSS_URL: "${config.sops.placeholder."freshrss-mcp-url"}"
          FRESHRSS_USER: "${config.sops.placeholder."freshrss-mcp-user"}"
          FRESHRSS_API_PASSWORD: "${config.sops.placeholder."freshrss-mcp-api-password"}"
      ntfy:
        description: "ntfy push notifications"
        command: ntfy-mcp
        env:
          NTFY_URL: "${config.sops.placeholder."ntfy-mcp-url"}"
          NTFY_TOPICS: "${ntfyTopics}"
      lrclib:
        description: "LRCLIB lyrics search, plain and time-synced (keyless)"
        command: mcp-lrclib
      musicbrainz:
        description: "MusicBrainz music metadata, cover art, tags/ratings (reads keyless)"
        command: musicbrainz-mcp
      open-meteo:
        description: "Open-Meteo weather forecast and geocoding (keyless)"
        command: open-meteo-mcp-server
      nixos:
        description: "NixOS package and option search"
        command: /home/gateway/.local/bin/mcp-nixos
      vet:
        description: "SafeDep vet supply-chain scanning"
        command: vet -l /tmp/vet-mcp.log server mcp --server-type stdio
        env:
          VET_DISABLE_TELEMETRY: "true"
      playwright:
        description: "Undetected browser automation (Patchright)"
        command: mcp-server-patchright --config /etc/playwright-mcp/config.json --no-sandbox --user-data-dir /home/gateway/.playwright-mcp
  '';

  home.file.".config/playwright-mcp/config.json".text = ''
    {
      "browser": {
        "launchOptions": {
          "channel": "chrome",
          "headless": true
        },
        "contextOptions": {
          "locale": "hu-HU",
          "timezoneId": "Europe/Budapest",
          "viewport": {"width": 1440, "height": 900}
        }
      }
    }
  '';

  home.file.".config/containers/systemd/mcp-gateway.build".text = ''
    [Unit]
    Description=mcp-gateway image build

    [Build]
    ImageTag=localhost/mcp-gateway:latest
    File=${containerfile}
    SetWorkingDirectory=${slskSrc}
  '';

  home.file.".config/containers/systemd/mcp-gateway.container".text = ''
    [Unit]
    Description=mcp-gateway
    After=network-online.target

    [Container]
    ContainerName=mcp-gateway
    Image=mcp-gateway.build
    UserNS=keep-id:uid=1001,gid=1001

    Network=container:openwebui

    Volume=${home}/.config/sops-nix/secrets/rendered/mcp-gateway-config:/config.yaml:ro
    Volume=${home}/containers/navidrome/music:/music
    Volume=${home}/containers/playwright-mcp:/home/gateway/.playwright-mcp
    Volume=${home}/.config/playwright-mcp/config.json:/etc/playwright-mcp/config.json:ro

    Environment=MCP_GATEWAY_LOG_LEVEL=info

    [Service]
    Restart=on-failure
    TimeoutStartSec=900

    [Install]
    WantedBy=default.target
  '';
}
