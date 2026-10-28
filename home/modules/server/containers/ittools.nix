{...}: {
  home.file.".config/containers/systemd/ittools.container".text = ''
    [Unit]
    Description=IT Tools container
    After=network-online.target

    [Container]
    ContainerName=ittools
    Image=ghcr.io/sharevb/it-tools:2026.10.25

    PublishPort=127.0.0.1:57001:8080

    [Install]
    WantedBy=default.target

    [Service]
    Restart=always
  '';
}
