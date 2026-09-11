{config, ...}: {
  homelab.containerDirs = ["${config.home.homeDirectory}/containers/forgejo/data" "${config.home.homeDirectory}/containers/forgejo/config"];

  sops.secrets = {
    "forgejo-domain" = {};
    "forgejo-lfs-jwt-secret" = {};
    "forgejo-internal-token" = {};
    "forgejo-oauth2-secret" = {};
  };

  sops.templates."forgejo-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/forgejo.container";
    content = ''
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
      Environment=FORGEJO____APP_NAME=csd4ni3l Git
      Environment=FORGEJO____APP_SLOGAN=Beyond coding. We Forge.
      Environment=FORGEJO____RUN_USER=git
      Environment=FORGEJO____RUN_MODE=prod

      Environment=FORGEJO__database__DB_TYPE=sqlite3
      Environment=FORGEJO__database__PATH=/var/lib/gitea/forgejo.db

      Environment=FORGEJO__server__SSH_DOMAIN=${config.sops.placeholder."forgejo-domain"}
      Environment=FORGEJO__server__DOMAIN=${config.sops.placeholder."forgejo-domain"}
      Environment=FORGEJO__server__HTTP_PORT=3000
      Environment=FORGEJO__server__ROOT_URL=https://${config.sops.placeholder."forgejo-domain"}
      Environment=FORGEJO__server__SSH_PORT=22
      Environment=FORGEJO__server__LFS_START_SERVER=true
      Environment=FORGEJO__server__LFS_JWT_SECRET=${config.sops.placeholder."forgejo-lfs-jwt-secret"}
      Environment=FORGEJO__server__OFFLINE_MODE=true
      Environment=FORGEJO__server__DISABLE_SSH=true

      Environment=FORGEJO__service__REGISTER_EMAIL_CONFIRM=false
      Environment=FORGEJO__service__ENABLE_NOTIFY_MAIL=false
      Environment=FORGEJO__service__DISABLE_REGISTRATION=true
      Environment=FORGEJO__service__ALLOW_ONLY_EXTERNAL_REGISTRATION=false
      Environment=FORGEJO__service__ENABLE_CAPTCHA=true
      Environment=FORGEJO__service__REQUIRE_SIGNIN_VIEW=false
      Environment=FORGEJO__service__DEFAULT_KEEP_EMAIL_PRIVATE=true
      Environment=FORGEJO__service__DEFAULT_ALLOW_CREATE_ORGANIZATION=true
      Environment=FORGEJO__service__DEFAULT_ENABLE_TIMETRACKING=true
      Environment=FORGEJO__service__NO_REPLY_ADDRESS=noreply.localhost

      Environment=FORGEJO__security__INSTALL_LOCK=true
      Environment=FORGEJO__security__INTERNAL_TOKEN=${config.sops.placeholder."forgejo-internal-token"}
      Environment=FORGEJO__security__PASSWORD_HASH_ALGO=pbkdf2_hi

      Environment=FORGEJO__oauth2__JWT_SECRET=${config.sops.placeholder."forgejo-oauth2-secret"}
      Environment=FORGEJO__oauth2__ENABLED=false

      Environment=FORGEJO__openid__ENABLE_OPENID_SIGNIN=false
      Environment=FORGEJO__openid__ENABLE_OPENID_SIGNUP=false

      Environment=FORGEJO__packages__ENABLED=true
      Environment=FORGEJO__mailer__ENABLED=false

      [Install]
      WantedBy=default.target

      [Service]
      Restart=always
    '';
  };
}
