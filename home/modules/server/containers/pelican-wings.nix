{config, ...}: {
  homelab.containerDirs = [
    "${config.home.homeDirectory}/containers/wings/etc"
    "${config.home.homeDirectory}/containers/wings/lib"
    "${config.home.homeDirectory}/containers/wings/log"
    "${config.home.homeDirectory}/containers/wings/tmp"
  ];

  home.file = {
    ".config/containers/systemd/wings.network".text = ''
      [Unit]
      Description=Wings Network

      [Network]
      Subnet=172.21.0.0/16
      NetworkName=wings0
    '';

    ".config/containers/systemd/wings.container".text = ''
      [Unit]
      Description=Pelican Wings
      After=network-online.target

      [Container]
      ContainerName=pelican-wings
      AutoUpdate=registry
      Image=ghcr.io/pelican-dev/wings:latest
      Network=wings.network

      Environment=TZ=Europe/Budapest
      Environment=WINGS_UID=1002
      Environment=WINGS_GID=100
      Environment=WINGS_USERNAME=pelican

      PublishPort=127.0.0.1:54001:8080

      # Point at Podman's docker-compatible rootless socket instead of dockerd
      Volume=%t/podman/podman.sock:/var/run/docker.sock
      Volume=%h/.local/share/containers/storage:/var/lib/docker/containers/:ro
      Volume=%h/containers/wings/etc:/etc/pelican/
      Volume=%h/containers/wings/lib:/var/lib/pelican/
      Volume=%h/containers/wings/log:/var/log/pelican/
      Volume=%h/containers/wings/tmp:/tmp/pelican/
      Volume=/etc/ssl/certs:/etc/ssl/certs:ro

      PodmanArgs=--tty

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';
  };
}
