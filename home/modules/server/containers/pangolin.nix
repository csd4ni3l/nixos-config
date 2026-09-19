{config, ...}: {
  homelab.containerDirs = [
    "${config.home.homeDirectory}/containers/pangolin/config/crowdsec"
    "${config.home.homeDirectory}/containers/pangolin/config/crowdsec/db"
    "${config.home.homeDirectory}/containers/pangolin/config/traefik/logs"
    "${config.home.homeDirectory}/containers/pangolin/config/letsencrypt"
  ];

  home.file = {
    ".config/containers/systemd/pangolin.network".text = ''
      [Network]
      NetworkName=pangolin
      Subnet=172.20.0.0/24
      Gateway=172.20.0.1
      IPv6=true
    '';

    ".config/containers/systemd/pangolin.container".text = ''
      [Unit]
      Description=Pangolin Control Panel
      After=network-online.target

      [Container]
      ContainerName=pangolin
      Image=docker.io/fosrl/pangolin:1.23.0

      Network=pangolin.network

      Volume=%h/containers/pangolin/config:/app/config:Z

      HealthCmd=curl -f http://localhost:3001/api/v1/
      HealthInterval=10s
      HealthRetries=15
      HealthTimeout=10s

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';

    ".config/containers/systemd/crowdsec.container".text = ''
      [Unit]
      Description=CrowdSec
      After=network-online.target

      [Container]
      ContainerName=crowdsec
      AutoUpdate=registry
      Image=crowdsecurity/crowdsec:latest

      Network=pangolin.network

      PublishPort=127.0.0.1:8080:8080

      Exec=-t

      Volume=%h/containers/pangolin/config/crowdsec:/etc/crowdsec:Z
      Volume=%h/containers/pangolin/config/crowdsec/db:/var/lib/crowdsec/data:Z
      Volume=%h/containers/pangolin/config/traefik/logs:/var/log/traefik:Z

      Environment=COLLECTIONS=crowdsecurity/traefik crowdsecurity/appsec-virtual-patching crowdsecurity/appsec-generic-rules
      Environment=ENROLL_INSTANCE_NAME=pangolin-crowdsec
      Environment=ENROLL_TAGS=docker
      Environment=GID=1000
      Environment=PARSERS=crowdsecurity/whitelists

      HealthCmd=cscli lapi status
      HealthInterval=10s
      HealthRetries=3
      HealthStartPeriod=30s
      HealthTimeout=5s

      [Service]
      Restart=on-failure

      [Install]
      WantedBy=default.target
    '';

    ".config/containers/systemd/gerbil.container".text = ''
      [Unit]
      Description=Gerbil Tunnel
      After=network-online.target
      After=pangolin.service

      [Container]
      ContainerName=gerbil
      AutoUpdate=registry
      Image=docker.io/fosrl/gerbil:latest

      Network=pangolin.network

      AddCapability=NET_ADMIN
      AddDevice=/dev/net/tun

      PublishPort=51820:51820/udp
      PublishPort=42712:42712/udp
      PublishPort=42712:42712/tcp
      PublishPort=63536:63536/udp
      PublishPort=80:80
      PublishPort=443:443

      Exec=--reachableAt=http://gerbil:3004 --generateAndSaveKeyTo=/var/config/key --remoteConfig=http://pangolin:3001/api/v1/

      Volume=%h/containers/pangolin/config:/var/config:Z

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';

    ".config/containers/systemd/traefik.container".text = ''
      [Unit]
      Description=Traefik Reverse Proxy
      After=network-online.target
      After=pangolin.service
      After=crowdsec.service

      [Container]
      ContainerName=traefik
      Image=docker.io/traefik:v3.7.13

      Network=gerbil.container

      Exec=--configFile=/etc/traefik/traefik_config.yml

      Volume=%h/containers/pangolin/config/traefik:/etc/traefik:ro,Z
      Volume=%h/containers/pangolin/config/letsencrypt:/letsencrypt:Z

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';
  };
}
