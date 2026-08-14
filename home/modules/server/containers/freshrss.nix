{config, ...}: {
  homelab.containerDirs = [
    "${config.home.homeDirectory}/containers/freshrss/data"
    "${config.home.homeDirectory}/containers/freshrss/extensions"
  ];

  home.file = {
    ".config/containers/systemd/freshrss.container".text = ''
      [Unit]
      Description=FreshRSS container
      After=network-online.target

      [Container]
      AutoUpdate=registry
      Image=docker.io/freshrss/freshrss:alpine

      PublishPort=127.0.0.1:58001:8080

      Environment=TZ=Europe/Budapest
      Environment=CRON_MIN=1,31

      Volume=%h/containers/freshrss/data:/var/www/FreshRSS/data:Z
      Volume=%h/containers/freshrss/extensions:/var/www/FreshRSS/extensions:Z

      [Install]
      WantedBy=default.target

      [Service]
      Restart=always
    '';
  };
}
