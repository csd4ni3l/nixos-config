{config, ...}: {
  homelab.containerDirs = ["${config.home.homeDirectory}/containers/forgejo/data"];

  home.file.".config/containers/systemd/forgejo.container".text = ''
    [Unit]
    Description=Forgejo container
    After=network-online.target

    [Container]
    ContainerName=forgejo
    AutoUpdate=registry
    Image=codeberg.org/forgejo/forgejo:16

    Environment=USER_UID=1001
    Environment=USER_GID=1001

    PublishPort=127.0.0.1:59001:3000

    Volume=%h/containers/forgejo/data:/data:Z
    Volume=/etc/localtime:/etc/localtime:ro

    [Install]
    WantedBy=default.target

    [Service]
    Restart=always
  '';
}
