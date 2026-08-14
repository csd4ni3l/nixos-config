{...}: {
  home.file = {
    "containers/wings/etc/.keep".text = "";
    "containers/wings/lib/.keep".text = "";
    "containers/wings/log/.keep".text = "";
    "containers/wings/tmp/.keep".text = "";
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

      [Container]
      AutoUpdate=registry
      Image=ghcr.io/pelican-dev/wings:latest
      Network=wings.network

      Environment=TZ=Europe/Budapest
      Environment=WINGS_UID=988
      Environment=WINGS_GID=988
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
