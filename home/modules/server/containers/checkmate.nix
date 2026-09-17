{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  homelab.containerDirs = [
    "${config.home.homeDirectory}/containers/checkmate/db"
  ];

  sops.secrets."checkmate-domain" = {};
  sops.secrets."checkmate-jwt-secret" = {};
  sops.secrets."checkmate-encryption-key" = {};

  home.file.".config/containers/systemd/checkmate.network".text = ''
    [Network]
    NetworkName=checkmate
  '';

  sops.templates."checkmate-mongo-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/checkmate-mongo.container";
    content = ''
      [Unit]
      Description=Checkmate MongoDB backend
      Wants=network-online.target
      After=network-online.target

      [Container]
      Image=docker.io/library/mongo:8.0
      AutoUpdate=registry
      ContainerName=checkmate-mongo
      Network=checkmate.network
      Exec=mongod --quiet --bind_ip_all
      Volume=${config.home.homeDirectory}/containers/checkmate/db:/data/db:Z
      HealthCmd=mongosh --eval "db.adminCommand('ping')" --quiet
      HealthInterval=5s
      HealthTimeout=30s
      HealthRetries=30

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';
  };

  sops.templates."checkmate-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/checkmate.container";
    content = ''
      [Unit]
      Description=Checkmate uptime & infrastructure monitoring
      Wants=network-online.target
      After=network-online.target checkmate-mongo.container
      Requires=checkmate-mongo.container

      [Container]
      Image=ghcr.io/bluewave-labs/checkmate:latest
      AutoUpdate=registry
      ContainerName=checkmate
      Network=checkmate.network
      Environment=TZ=Europe/Budapest
      Environment=DB_CONNECTION_STRING=mongodb://checkmate-mongo:27017/uptime_db
      Environment=CLIENT_HOST=https://${config.sops.placeholder."checkmate-domain"}
      Environment=JWT_SECRET=${config.sops.placeholder."checkmate-jwt-secret"}
      Environment=ENCRYPTION_KEY=${config.sops.placeholder."checkmate-encryption-key"}
      Environment=NODE_ENV=production
      PublishPort=127.0.0.1:52345:52345
      HealthCmd=node -e "require('http').get('http://127.0.0.1:52346/livez',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"
      HealthInterval=15s
      HealthTimeout=3s
      HealthStartPeriod=60s
      HealthRetries=3
      StopTimeout=60

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';
  };
}
