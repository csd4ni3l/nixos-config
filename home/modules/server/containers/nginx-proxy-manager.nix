{...}: {
  home.file.".config/containers/systemd/nginx-proxy-manager.container".text = ''
    [Unit]
    Description=NginxProxyManager

    [Container]
    AutoUpdate=registry
    Image=docker.io/jc21/nginx-proxy-manager:latest

    NetworkMode=host

    Volume=%h/containers/nginx-proxy-manager/data:/data:Z
    Volume=%h/containers/nginx-proxy-manager/letsencrypt:/letsencrypt:Z

    [Service]
    Restart=on-failure

    [Install]
    WantedBy=default.target
  '';
}
