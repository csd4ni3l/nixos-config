# the terminal itself is unrestricted, but the only host paths inside it are the music dir and
# its own workdir, and it has no port published and no route from the host, so only openwebui
# can reach it
{
  config,
  pkgs,
  inputs,
  ...
}: let
  containerfile = pkgs.writeText "open-terminal-Containerfile" ''
    FROM ghcr.io/open-webui/open-terminal@sha256:cd371210322ed3f8b669896a2b3d0929c9e9985ac0e529f50e50098b813aafd8

    USER root
    ENTRYPOINT []

    RUN apk add --no-cache \
      bash-completion \
      coreutils \
      fd \
      file \
      ffmpeg \
      py3-pip \
      ripgrep \
      rsync \
      sqlite \
      tree \
      unzip \
      xz \
      jq \
      git \
      curl \
      wget

    RUN printf 'export PATH="$HOME/.local/bin:$PATH"\n' > /home/user/.profile \
      && cp /home/user/.profile /home/user/.bashrc \
      && mkdir -p /home/user/.local/bin

    ENV HOME=/home/user
    ENV SHELL=/bin/bash
    WORKDIR /workdir
    CMD ["open-terminal", "run"]
  '';
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  homelab.containerDirs = ["${config.home.homeDirectory}/containers/open-terminal/workdir"];

  sops.secrets."open-terminal-apikey" = {};

  sops.templates."open-terminal-config" = {
    path = "${config.home.homeDirectory}/.config/sops-nix/secrets/rendered/open-terminal.toml";
    content = ''
      host = "0.0.0.0"
      port = 8010
      api_key = "${config.sops.placeholder."open-terminal-apikey"}"
    '';
  };

  home.file.".config/containers/systemd/open-terminal.build".text = ''
    [Unit]
    Description=open-terminal image build
    [Build]
    ImageTag=localhost/open-terminal:latest
    File=${containerfile}
  '';

  sops.templates."open-terminal-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/open-terminal.container";
    content = ''
      [Unit]
      Description=open-terminal
      After=network-online.target

      [Container]
      ContainerName=open-terminal
      Image=open-terminal.build
      UserNS=keep-id

      Network=container:openwebui

      Volume=/home/${config.home.username}/.config/sops-nix/secrets/rendered/open-terminal.toml:/etc/open-terminal/config.toml:ro
      Volume=/home/${config.home.username}/containers/navidrome/music:/music
      Volume=/home/${config.home.username}/containers/open-terminal/workdir:/workdir

      # only a hint for the file browser in the openwebui sidebar, not a sandbox
      Environment=OPEN_TERMINAL_FILE_BROWSER_ROOT=/workdir

      [Service]
      Restart=on-failure
      TimeoutStartSec=300

      [Install]
      WantedBy=default.target
    '';
  };
}
