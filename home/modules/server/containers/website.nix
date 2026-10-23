{config, ...}: {
  home.file.".config/containers/systemd/website.container".text = ''
    [Unit]
    Description=Website container
    After=network-online.target

    [Container]
    ContainerName=website
    Image=git.csd4ni3l.hu/csd4ni3l/website:latest@sha256:55bf1385660f7f6f466d395dfc67090d5c11881eee8ec1dd4d26be66c04a710a

    PublishPort=127.0.0.1:62001:80

    [Install]
    WantedBy=default.target

    [Service]
    Restart=always
  '';
}
