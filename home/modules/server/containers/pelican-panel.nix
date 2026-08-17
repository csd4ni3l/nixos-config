{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  homelab.containerDirs = [
    "${config.home.homeDirectory}/containers/pelican/data"
    "${config.home.homeDirectory}/containers/pelican/logs"
    "${config.home.homeDirectory}/containers/pelican/plugins"
  ];

  sops.secrets."pelican-panel-domain" = {};
  sops.secrets."pelican-panel-app-key" = {};

  sops.templates."pelican-panel-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/pelican-panel.container";
    content = ''
      [Unit]
      Description=Pelican panel

      [Container]
      ContainerName=pelican-panel
      AutoUpdate=registry
      Image=ghcr.io/pelican-dev/panel:latest

      Environment=APP_URL="${config.sops.placeholder."pelican-panel-domain"}"
      Environment=APP_KEY=${config.sops.placeholder."pelican-panel-app-key"}
      Environment=APP_DEBUG="false"
      Environment=APP_ENV="production"

      PublishPort=127.0.0.1:55001:8080

      Volume=%h/containers/pelican/data:/pelican-data
      Volume=%h/containers/pelican/logs:/var/www/html/storage/logs
      Volume=%h/containers/pelican/plugins:/var/www/html/plugins

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';
  };
}
