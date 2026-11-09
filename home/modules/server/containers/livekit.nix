{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  homelab.containerDirs = ["${config.home.homeDirectory}/containers/livekit/config"];

  sops.secrets."livekit-api-key" = {};
  sops.secrets."livekit-api-secret" = {};

  sops.templates."livekit-config" = {
    path = "${config.home.homeDirectory}/containers/livekit/config/livekit.yaml";
    content = ''
      port: 7880
      log_level: info

      rtc:
        tcp_port: 7881
        port_range_start: 50000
        port_range_end: 50200
        use_external_ip: true

      keys:
        ${config.sops.placeholder."livekit-api-key"}: ${config.sops.placeholder."livekit-api-secret"}
    '';
  };

  home.file.".config/containers/systemd/livekit.container".text = ''
    [Unit]
    Description=LiveKit WebRTC Server
    Wants=network-online.target
    After=network-online.target

    [Container]
    Image=docker.io/livekit/livekit-server:v1.13.11
    ContainerName=livekit

    Network=pangolin.network

    # RTC media, the only ports that must be reachable from the internet.
    PublishPort=50000-50200:50000-50200/udp

    Volume=%h/containers/livekit/config/livekit.yaml:/etc/livekit.yaml:ro,Z

    Exec=--config /etc/livekit.yaml

    [Service]
    Restart=always

    [Install]
    WantedBy=default.target
  '';
}
