{...}: {
  home.file.".config/containers/systemd/ittools.container".text = ''
    [Unit]
    Description=IT Tools container
    After=network-online.target

    [Container]
    AutoUpdate=registry
    Image=ghcr.io/sharevb/it-tools:latest

    PublishPort=127.0.0.1:57001:8080

    [Install]
    WantedBy=multi-user.target default.target

    [Service]
    Restart=always
  '';
}
