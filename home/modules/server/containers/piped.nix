{
  config,
  inputs,
  ...
}: let
  quadletDir = "${config.home.homeDirectory}/.config/containers/systemd";
  containerDir = "${config.home.homeDirectory}/containers/piped";
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops.secrets."pipedapi-domain" = {};
  sops.secrets."pipedfrontend-domain" = {};
  sops.secrets."pipedproxy-domain" = {};
  sops.secrets."piped-postgres-password" = {};

  homelab.containerDirs = ["${containerDir}/data/db"];

  sops.templates."piped-config-properties" = {
    path = "${containerDir}/config/config.properties";
    content = ''
      # The port to Listen on.
      PORT: 8080

      # The number of workers to use for the server
      HTTP_WORKERS: 2

      # Proxy
      PROXY_PART: https://${config.sops.placeholder."pipedproxy-domain"}

      # Public API URL
      API_URL: https://${config.sops.placeholder."pipedapi-domain"}

      # Public Frontend URL
      FRONTEND_URL: https://${config.sops.placeholder."pipedfrontend-domain"}

      # Enable haveibeenpwned compromised password API
      COMPROMISED_PASSWORD_CHECK: true

      # Disable Registration
      DISABLE_REGISTRATION: true

      # Feed Retention Time in Days
      FEED_RETENTION: 30

      # Disable CPU expensive timers (for nodes with low CPU, at least one node should have this disabled)
      DISABLE_TIMERS: false

      # RYD Proxy URL (see https://github.com/TeamPiped/RYD-Proxy)
      RYD_PROXY_URL: https://ryd-proxy.kavin.rocks

      # SponsorBlock Servers(s)
      # Comma separated list of SponsorBlock Servers to use
      SPONSORBLOCK_SERVERS: https://sponsor.ajay.app,https://sponsorblock.kavin.rocks

      # Disable the usage of RYD
      DISABLE_RYD: false

      # Disable API server (node just runs timers if enabled)
      DISABLE_SERVER: false

      # Disable the inclusion of LBRY streams
      DISABLE_LBRY: false

      # How long should unauthenticated subscriptions last for
      SUBSCRIPTIONS_EXPIRY: 30

      # Send consent accepted cookie
      # This is required for certain features to work in some countries
      CONSENT_COOKIE: true

      # BG Helper URL for supplying PoTokens
      BG_HELPER_URL: http://piped-bg-helper:3000

      # Hibernate properties
      hibernate.connection.url: jdbc:postgresql://piped-postgres:5432/piped
      hibernate.connection.driver_class: org.postgresql.Driver
      hibernate.dialect: org.hibernate.dialect.PostgreSQLDialect
      hibernate.connection.username: piped
      hibernate.connection.password: ${config.sops.placeholder."piped-postgres-password"}
    '';
  };

  sops.templates."piped-frontend-container" = {
    path = "${quadletDir}/piped-frontend.container";
    content = ''
      [Unit]
      Description=Piped Frontend
      After=piped-backend.service
      Requires=piped-backend.service

      [Container]
      AutoUpdate=registry
      User=0
      Image=docker.io/logicalkarma/piped-frontend:experimental
      ContainerName=piped-frontend
      Network=piped.network
      Environment=BACKEND_HOSTNAME=${config.sops.placeholder."pipedapi-domain"}
      Environment=HTTP_MODE=https
      Environment=HTTP_PORT=8080

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';
  };
  sops.templates."piped-postgres-container" = {
    path = "${quadletDir}/piped-postgres.container";
    content = ''
      [Unit]
      Description=Piped Postgres
      After=network-online.target

      [Container]
      UserNS=keep-id
      AutoUpdate=registry
      Image=docker.io/pgautoupgrade/pgautoupgrade:16-alpine
      ContainerName=piped-postgres
      Network=piped.network
      Volume=%h/containers/piped/data/db:/var/lib/postgresql/data:Z
      Environment=POSTGRES_DB=piped
      Environment=POSTGRES_USER=piped
      Environment=POSTGRES_PASSWORD=${config.sops.placeholder."piped-postgres-password"}

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';
  };

  home.file."${containerDir}/config/nginx.conf".text = ''
    user root;
    worker_processes auto;

    error_log /var/log/nginx/error.log notice;
    pid /var/run/nginx.pid;

    events {
        worker_connections 1024;
    }

    http {
        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        server_names_hash_bucket_size 128;

        log_format main '$remote_addr - $remote_user [$time_local] "$request" '
        '$status $body_bytes_sent "$http_referer" '
        '"$http_user_agent" "$http_x_forwarded_for"';

        access_log /var/log/nginx/access.log main;

        sendfile on;
        tcp_nodelay on;

        keepalive_timeout 65;

        include /etc/nginx/conf.d/*.conf;
    }
  '';

  sops.templates."pipedapi-conf" = {
    path = "${containerDir}/config/pipedapi.conf";
    content = ''
      proxy_cache_path /tmp/pipedapi_cache levels=1:2 keys_zone=pipedapi:4m max_size=2g inactive=60m use_temp_path=off;

      upstream backend {
          server piped-backend:8080;
      }
      server {
          listen 80;
          server_name ${config.sops.placeholder."pipedapi-domain"};

          location / {
              proxy_cache pipedapi;
              proxy_pass http://backend;
              proxy_http_version 1.1;
              proxy_set_header Connection "keep-alive";
          }
      }
    '';
  };

  sops.templates."pipedproxy-conf" = {
    path = "${containerDir}/config/pipedproxy.conf";
    content = ''
      server {
          listen 80;
          server_name ${config.sops.placeholder."pipedproxy-domain"};

          location ~ (/videoplayback|/api/v4/|/api/manifest/) {
              include snippets/ytproxy.conf;
              add_header Cache-Control private always;
          }

          location / {
              include snippets/ytproxy.conf;
              add_header Cache-Control "public, max-age=604800";
          }
      }
    '';
  };

  sops.templates."pipedfrontend-conf" = {
    path = "${containerDir}/config/pipedfrontend.conf";
    content = ''
      upstream frontend {
          server piped-frontend:8080;
      }
      server {
          listen 80;
          server_name ${config.sops.placeholder."pipedfrontend-domain"};

          location / {
              proxy_pass http://frontend;
              proxy_http_version 1.1;
              proxy_set_header Connection "keep-alive";
          }
      }
    '';
  };

  home.file."${containerDir}/config/ytproxy.conf".text = ''
    proxy_pass http://unix:/var/run/ytproxy/actix.sock;
    proxy_http_version 1.1;
    proxy_set_header Connection "keep-alive";
    proxy_buffering off;
  '';

  home.file = {
    "${quadletDir}/piped.network".text = ''
      [Network]
      NetworkName=piped
    '';

    "${quadletDir}/piped-proxy.volume".text = ''
      [Volume]
      VolumeName=piped-proxy
    '';

    "${quadletDir}/piped-proxy.container".text = ''
      [Unit]
      Description=Piped Proxy
      After=network-online.target

      [Container]
      AutoUpdate=registry
      Image=docker.io/logicalkarma/piped-proxy:experimental
      ContainerName=piped-proxy
      Network=piped.network
      Environment=UDS=1
      Volume=piped-proxy.volume:/app/socket

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';

    "${quadletDir}/piped-backend.container".text = ''
      [Unit]
      Description=Piped Backend
      After=piped-postgres.service
      Requires=piped-postgres.service

      [Container]
      AutoUpdate=registry
      Image=docker.io/logicalkarma/piped:experimental
      ContainerName=piped-backend
      Network=piped.network
      Volume=%h/containers/piped/config/config.properties:/app/config.properties:ro

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';

    "${quadletDir}/piped-bg-helper.container".text = ''
      [Unit]
      Description=Piped BG Helper
      After=network-online.target

      [Container]
      AutoUpdate=registry
      Image=docker.io/1337kavin/bg-helper-server:latest
      ContainerName=piped-bg-helper
      Network=piped.network

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';

    "${quadletDir}/piped-nginx.container".text = ''
      [Unit]
      Description=Piped Nginx
      After=piped-backend.service piped-proxy.service piped-frontend.service
      Requires=piped-backend.service piped-proxy.service piped-frontend.service

      [Container]
      AutoUpdate=registry
      Image=docker.io/library/nginx:mainline-alpine
      ContainerName=piped-nginx
      Network=piped.network
      PublishPort=127.0.0.1:53001:80
      Volume=%h/containers/piped/config/nginx.conf:/etc/nginx/nginx.conf:ro
      Volume=%h/containers/piped/config/pipedapi.conf:/etc/nginx/conf.d/pipedapi.conf:ro
      Volume=%h/containers/piped/config/pipedproxy.conf:/etc/nginx/conf.d/pipedproxy.conf:ro
      Volume=%h/containers/piped/config/pipedfrontend.conf:/etc/nginx/conf.d/pipedfrontend.conf:ro
      Volume=%h/containers/piped/config/ytproxy.conf:/etc/nginx/snippets/ytproxy.conf:ro
      Volume=piped-proxy.volume:/var/run/ytproxy

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';
  };
}
