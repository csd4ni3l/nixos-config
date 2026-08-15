{config, inputs, ...}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  homelab.containerDirs = [
    "${config.home.homeDirectory}/containers/freshrss/data"
    "${config.home.homeDirectory}/containers/freshrss/db"
    "${config.home.homeDirectory}/containers/freshrss/extensions"
  ];

  sops.secrets."freshrss-postgres-password" = {};

  sops.templates."freshrss-postgres-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/freshrss-postgres.container";
    content = ''
      [Unit]
      Description=FreshRSS Postgres
      After=network-online.target

      [Container]
      UserNS=keep-id
      AutoUpdate=registry
      Image=docker.io/postgres:16-alpine
      ContainerName=freshrss-postgres

      Network=freshrss.network

      Volume=%h/containers/freshrss/db:/var/lib/postgresql/data:Z

      Environment=POSTGRES_DB=freshrss
      Environment=POSTGRES_USER=freshrss
      Environment=POSTGRES_PASSWORD=${config.sops.placeholder."freshrss-postgres-password"}

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';
  };

  home.file = {
    ".config/containers/systemd/freshrss.network".text = ''
      [Network]
      NetworkName=freshrss
    '';

    ".config/containers/systemd/freshrss.container".text = ''
      [Unit]
      Description=FreshRSS container
      After=network-online.target

      [Container]
      ContainerName=freshrss
      AutoUpdate=registry
      Image=lscr.io/linuxserver/freshrss:latest
      UserNS=keep-id:uid=1001,gid=100

      Network=freshrss.network

      PublishPort=127.0.0.1:58001:80

      Environment=PUID=1001
      Environment=PGID=100
      Environment=TZ=Europe/Budapest
      Environment=CRON_MIN=1,31

      Volume=%h/containers/freshrss/data:/config/www/freshrss/data:Z
      Volume=%h/containers/freshrss/extensions:/config/www/freshrss/extensions:Z

      [Install]
      WantedBy=default.target

      [Service]
      Restart=always
    '';
  };

}
