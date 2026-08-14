{config, ...}: {
  homelab.containerDirs = [
    "${config.home.homeDirectory}/containers/nginx-proxy-manager/data"
    "${config.home.homeDirectory}/containers/nginx-proxy-manager/letsencrypt"
  ];

  home.file.".config/containers/systemd/nginx-proxy-manager.container".text = ''
    [Unit]
    Description=NginxProxyManager Container

    [Container]
    AutoUpdate=registry
    Image=docker.io/jc21/nginx-proxy-manager:latest

    Network=host

    Volume=%h/containers/nginx-proxy-manager/data:/data:Z
    Volume=%h/containers/nginx-proxy-manager/letsencrypt:/etc/letsencrypt:Z

    [Service]
    Restart=on-failure

    [Install]
    WantedBy=default.target
  '';
}
