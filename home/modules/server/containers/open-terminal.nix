# the terminal itself is unrestricted, but the only host paths inside it are the music dir and
# its own workdir, and it has no port published and no route from the host, so only openwebui
# can reach it
{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  homelab.containerDirs = ["${config.home.homeDirectory}/containers/open-terminal/workdir"];

  sops.secrets."open-terminal-apikey" = {};

  # port is in here because the image only takes host/port from a config file, and 8000
  # is already taken inside the openwebui netns by soulseek-mcp
  sops.templates."open-terminal-config" = {
    path = "${config.home.homeDirectory}/.config/sops-nix/secrets/rendered/open-terminal.toml";
    content = ''
      host = "0.0.0.0"
      port = 8010
      api_key = "${config.sops.placeholder."open-terminal-apikey"}"
    '';
  };

  sops.templates."open-terminal-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/open-terminal.container";
    content = ''
      [Unit]
      Description=open-terminal
      After=network-online.target

      [Container]
      ContainerName=open-terminal
      AutoUpdate=registry
      Image=ghcr.io/open-webui/open-terminal:alpine
      UserNS=keep-id:uid=1000,gid=1000

      Network=container:openwebui

      Volume=/home/${config.home.username}/.config/sops-nix/secrets/rendered/open-terminal.toml:/etc/open-terminal/config.toml:ro
      Volume=/home/${config.home.username}/containers/navidrome/music:/music
      Volume=/home/${config.home.username}/containers/open-terminal/workdir:/workdir

      # only a hint for the file browser in the openwebui sidebar, not a sandbox
      Environment=OPEN_TERMINAL_FILE_BROWSER_ROOT=/workdir

      [Service]
      Restart=on-failure

      [Install]
      WantedBy=default.target
    '';
  };
}
