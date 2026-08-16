{config, ...}: {
  home.file.".config/containers/systemd/website.container".text = ''
    [Unit]
    Description=Website container
    After=network-online.target

    [Container]
    ContainerName=website
    AutoUpdate=registry
    Image=git.csd4ni3l.hu/csd4ni3l/website:latest

    PublishPort=127.0.0.1:62001:80

    [Install]
    WantedBy=default.target

    [Service]
    Restart=always
  '';
}
