{config, ...}: {
  homelab.containerDirs = ["${config.home.homeDirectory}/containers/openwebui"];

  home.file.".config/containers/systemd/openwebui.container".text = ''
    [Unit]
    Description=OpenWebUI container
    After=network-online.target

    [Container]
    ContainerName=openwebui
    AutoUpdate=registry
    Image=ghcr.io/open-webui/open-webui:main

    PublishPort=127.0.0.1:64001:8080

    Volume=%h/containers/openwebui:/app/backend/data:Z

    [Service]
    Restart=always

    [Install]
    WantedBy=default.target
  '';
}
