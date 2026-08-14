{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  home.file = {
    "containers/pelican/data/.keep".text = "";
    "containers/pelican/logs/.keep".text = "";
    "containers/pelican/plugins/.keep".text = "";
  };

  sops.secrets."pelican-panel-domain" = {};

  sops.templates."pelican-panel-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/pelican-panel.container";
    content = ''
      [Unit]
      Description=Pelican panel
      After=wings.service
      Requires=wings.service

      [Container]
      AutoUpdate=registry
      Image=ghcr.io/pelican-dev/panel:latest
      Network=wings.network

      Environment=APP_URL="${config.sops.placeholder."pelican-panel-domain"}"
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
