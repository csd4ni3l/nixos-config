{config, ...}: {
  home.file."${config.home.homeDirectory}/.config/containers/systemd/privatebin.container" = ''
    [Unit]
    Description=PrivateBin

    [Container]
    AutoUpdate=registry
    Image=docker.io/privatebin/nginx-fpm-alpine

    PublishPort=127.0.0.1:52001:8080

    [Service]
    Restart=on-failure

    [Install]
    WantedBy=default.target
  '';
}
