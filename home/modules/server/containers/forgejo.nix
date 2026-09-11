{config, ...}: {
  homelab.containerDirs = ["${config.home.homeDirectory}/containers/forgejo/data" "${config.home.homeDirectory}/containers/forgejo/config"];

  sops.secrets = {
    "forgejo-user-password" = {};
    "forgejo-domain" = {};
    "forgejo-lfs-jwt-secret" = {};
    "forgejo-internal-token" = {};
    "forgejo-oauth2-secret" = {};
  };

  home.file.".config/containers/systemd/forgejo.container".text = ''
    [Unit]
    Description=Forgejo container
    After=network-online.target

    [Container]
    UserNS=keep-id:uid=1000,gid=1000
    ContainerName=forgejo
    AutoUpdate=registry
    Image=codeberg.org/forgejo/forgejo:16-rootless
    PublishPort=127.0.0.1:59001:3000
    Volume=%h/containers/forgejo/data:/var/lib/gitea:Z
    Volume=%h/containers/forgejo/config:/etc/gitea:Z
    Volume=/etc/localtime:/etc/localtime:ro

    Environment=GITEA_APP_INI=/etc/gitea/app.ini
    Environment=FORGEJO_APP_NAME=csd4ni3l Git
    Environment=FORGEJO_APP_SLOGAN=Beyond coding. We Forge.
    Environment=FORGEJO_RUN_USER=git
    Environment=FORGEJO_RUN_MODE=prod

    Environment=FORGEJO_DATABASE_DB_TYPE=sqlite3
    Environment=FORGEJO_DATABASE_PATH=/var/lib/gitea/forgejo.db
    Environment=FORGEJO_DATABASE_NAME=forgejo
    Environment=FORGEJO_DATABASE_USER=csd4ni3l
    Environment=FORGEJO_DATABASE_PASSWD=${config.sops.placeholder."forgejo-user-password"}

    Environment=FORGEJO_SERVER_SSH_DOMAIN=${config.sops.placeholder."forgejo-domain"}
    Environment=FORGEJO_SERVER_DOMAIN=${config.sops.placeholder."forgejo-domain"}
    Environment=FORGEJO_SERVER_HTTP_PORT=3000
    Environment=FORGEJO_SERVER_ROOT_URL=https://${config.sops.placeholder."forgejo-domain"}
    Environment=FORGEJO_SERVER_SSH_PORT=22
    Environment=FORGEJO_SERVER_LFS_START_SERVER=true
    Environment=FORGEJO_SERVER_LFS_JWT_SECRET=${config.sops.placeholder."forgejo-lfs-jwt-secret"}
    Environment=FORGEJO_SERVER_OFFLINE_MODE=true
    Environment=FORGEJO_SERVER_DISABLE_SSH=true

    Environment=FORGEJO_SERVICE_REGISTER_EMAIL_CONFIRM=false
    Environment=FORGEJO_SERVICE_ENABLE_NOTIFY_MAIL=false
    Environment=FORGEJO_SERVICE_DISABLE_REGISTRATION=true
    Environment=FORGEJO_SERVICE_ALLOW_ONLY_EXTERNAL_REGISTRATION=false
    Environment=FORGEJO_SERVICE_ENABLE_CAPTCHA=true
    Environment=FORGEJO_SERVICE_REQUIRE_SIGNIN_VIEW=false
    Environment=FORGEJO_SERVICE_DEFAULT_KEEP_EMAIL_PRIVATE=true
    Environment=FORGEJO_SERVICE_DEFAULT_ALLOW_CREATE_ORGANIZATION=true
    Environment=FORGEJO_SERVICE_DEFAULT_ENABLE_TIMETRACKING=true
    Environment=FORGEJO_SERVICE_NO_REPLY_ADDRESS=noreply.localhost

    Environment=FORGEJO_SECURITY_INSTALL_LOCK=true
    Environment=FORGEJO_SECURITY_INTERNAL_TOKEN=${config.sops.placeholder."forgejo-internal-token"}
    Environment=FORGEJO_SECURITY_PASSWORD_HASH_ALGO=pbkdf2_hi

    Environment=FORGEJO_OAUTH2_JWT_SECRET=${config.sops.placeholder."forgejo-oauth2-secret"}
    Environment=FORGEJO_OAUTH2_ENABLED=false

    Environment=FORGEJO_OPENID_ENABLE_OPENID_SIGNIN=false
    Environment=FORGEJO_OPENID_ENABLE_OPENID_SIGNUP=false

    Environment=FORGEJO_PACKAGES_ENABLED=true

    Environment=FORGEJO_MAILER_ENABLED=false

    [Install]
    WantedBy=default.target

    [Service]
    Restart=always
  '';
}
