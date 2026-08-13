{...}: {
  home.file.".config/containers/systemd/aonsoku.container".text = ''
    [Unit]
    Description=Aonsoku Container

    [Container]
    ContainerName=aonsoku
    Image=ghcr.io/victoralvesf/aonsoku:latest
    PublishPort=127.0.0.1:60001:8080
    AutoUpdate=registry

    [Service]
    Restart=always

    [Install]
    WantedBy=multi-user.target default.target
  '';
}
