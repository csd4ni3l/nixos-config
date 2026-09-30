# even though i dislike running nodejs or any AI heavy app in prod, this is safe because im putting it on the openwebui container network,
# so only openwebui can access it, and im not exposing even just openwebui to the internet
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  src = pkgs.applyPatches {
    name = "slsk-mcp-src";
    src = pkgs.fetchFromGitHub {
      owner = "voidtype";
      repo = "slsk_mcp";
      rev = "df06ca17e2931246b1f139abf028a22e808da7a3";
      hash = "sha256-fnBXTmAvGec6WPrjrj/tGF1Na99RM3VuRdVpls3lHgg=";
    };
    patches = [./slsk-dest-dir.patch];
  };

  containerfile = pkgs.writeText "slsk-mcp-Containerfile" ''
    FROM docker.io/library/python:3.12-slim
    COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
    WORKDIR /app
    COPY pyproject.toml uv.lock ./
    RUN uv sync --frozen --no-dev --no-install-project
    COPY . .
    RUN uv sync --frozen --no-dev
    RUN uv pip install --python /app/.venv/bin/python mcp-proxy==0.12.0
    ENV SLSK_DOWNLOAD_DIR=/downloads
    ENTRYPOINT ["/app/.venv/bin/mcp-proxy", "--pass-environment", "--host", "0.0.0.0", "--port", "8000", "--"]
    CMD ["/app/.venv/bin/slsk-mcp"]
  '';
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];
  sops.secrets."slsk-mcp-username" = {};
  sops.secrets."slsk-mcp-password" = {};
  sops.templates."slsk-mcp-env" = {
    path = "${config.home.homeDirectory}/.config/sops-nix/secrets/rendered/slsk-mcp.env";
    content = ''
      SLSK_USERNAME=${config.sops.placeholder."slsk-mcp-username"}
      SLSK_PASSWORD=${config.sops.placeholder."slsk-mcp-password"}
    '';
  };
  home.file.".config/containers/systemd/slsk-mcp.build".text = ''
    [Unit]
    Description=slsk-mcp image build
    [Build]
    ImageTag=localhost/slsk-mcp:latest
    File=${containerfile}
    SetWorkingDirectory=${src}
  '';
  sops.templates."slsk-mcp-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/slsk-mcp.container";
    content = ''
      [Unit]
      Description=slsk-mcp
      [Container]
      ContainerName=slsk-mcp
      Image=slsk-mcp.build
      UserNS=keep-id:uid=1000,gid=1000
      Network=container:openwebui
      EnvironmentFile=/home/${config.home.username}/.config/sops-nix/secrets/rendered/slsk-mcp.env
      Volume=/home/${config.home.username}/containers/navidrome/music:/music
      # base dir for downloads; the agent picks subfolders via dest_dir
      Environment=SLSK_DOWNLOAD_DIR=/music
      [Service]
      Restart=on-failure
      TimeoutStartSec=900
      [Install]
      WantedBy=default.target
    '';
  };
}
