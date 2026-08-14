{config, ...}: {
  homelab.containerDirs = [
    "${config.home.homeDirectory}/containers/qbittorrent/config"
    "${config.home.homeDirectory}/containers/qbittorrent/downloads"
    "${config.home.homeDirectory}/containers/qbittorrent/watch"
  ];

  home.file.".config/containers/systemd/qbittorrent.container".text = ''
    [Unit]
    Description=QBitTorrent Container

    [Container]
    ContainerName=qbittorrent
    Image=lscr.io/linuxserver/qbittorrent:latest
    AutoUpdate=registry

    Volume=%h/containers/qbittorrent/config:/config:Z
    Volume=%h/containers/qbittorrent/downloads:/downloads:Z
    Volume=%h/containers/qbittorrent/watch:/watch:Z

    PublishPort=127.0.0.1:61001:8080

    Environment=PUID=1000
    Environment=PGID=1000
    Environment=TZ=Europe/Budapest
    Environment=WEBUI_PORT=8080
    Environment=TORRENTING_PORT=6881

    [Service]
    Restart=always

    [Install]
    WantedBy=default.target
  '';
}
