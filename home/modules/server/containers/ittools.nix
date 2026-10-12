{...}: {
  home.file.".config/containers/systemd/ittools.container".text = ''
    [Unit]
    Description=IT Tools container
    After=network-online.target

    [Container]
    ContainerName=ittools
    AutoUpdate=registry
    Image=ghcr.io/sharevb/it-tools:2026.9.27

    PublishPort=127.0.0.1:57001:8080

    [Install]
    WantedBy=default.target

    [Service]
    Restart=always
  '';
}
