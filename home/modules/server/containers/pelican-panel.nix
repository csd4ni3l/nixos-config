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

  home.file."containers/pelican/Caddyfile".text = ''
    {
      admin off
      servers {
        trusted_proxies static 169.254.0.1 127.0.0.1
      }
    }

    :80 {
      root * /var/www/html/public
      encode gzip
      php_fastcgi 127.0.0.1:9000 {
        env PHP_VALUE "upload_max_filesize = 256M
        post_max_size = 256M"
      }
      file_server
    }
  '';

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
      Image=ghcr.io/pelican/panel:latest
      UserNS=keep-id:uid=82,gid=82

      Environment=APP_URL="${config.sops.placeholder."pelican-panel-domain"}"
      Environment=APP_KEY=${config.sops.placeholder."pelican-panel-app-key"}
      Environment=APP_DEBUG="false"
      Environment=APP_ENV="production"

      PublishPort=127.0.0.1:55001:80

      Volume=%h/containers/pelican/data:/pelican-data
      Volume=%h/containers/pelican/logs:/var/www/html/storage/logs
      Volume=%h/containers/pelican/plugins:/var/www/html/plugins
      Volume=%h/containers/pelican/Caddyfile:/etc/caddy/Caddyfile

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';
  };
}
