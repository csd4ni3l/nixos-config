{ config, pkgs, ... }: {
  home.file = {
    ".config/containers/containers.conf".text = ''
      [engine]
      log_driver = "journald"
    '';

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
      Image=ghcr.io/pelican/wings:latest
      Network=wings.network
      Environment=TZ=Europe/Budapest
      Environment=WINGS_UID=1002
      Environment=WINGS_GID=100
      Environment=WINGS_USERNAME=pelican
      PublishPort=127.0.0.1:54001:8080
      Volume=%t/podman/podman.sock:/var/run/docker.sock
      Volume=%h/.local/share/containers/storage:/var/lib/docker/containers/:ro
      Volume=/etc/pelican/:/etc/pelican/
      Volume=/var/lib/pelican/:/var/lib/pelican/
      Volume=/var/log/pelican/:/var/log/pelican/
      Volume=/tmp/pelican/:/tmp/pelican/
      Volume=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt:/etc/host-ca-bundle.crt:ro
      PodmanArgs=--tty
      [Service]
      Restart=always
      [Install]
      WantedBy=default.target
    '';
  };
}
