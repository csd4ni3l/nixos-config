{config, ...}: {
  homelab.containerDirs = ["${config.home.homeDirectory}/containers/forgejo/data"];

  sops.secrets."forgejo-user-password" = {};
  sops.secrets."forgejo-domain" = {};
  sops.secrets."forgejo-lfs-jwt-secret" = {};
  sops.secrets."forgejo-internal-token" = {};
  sops.secrets."forgejo-oauth2-secret" = {};

  sops.templates."forgejo-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/forgejo.container";
    content = ''
      [Unit]
      Description=Forgejo container
      After=network-online.target

      [Container]
      UserNS=keep-id:uid=1001,gid=100
      ContainerName=forgejo
      AutoUpdate=registry
      Image=codeberg.org/forgejo/forgejo:16

      Environment=USER_UID=1001
      Environment=USER_GID=100

      Environment=FORGEJO_APP_NAME="csd4ni3l Git"

      Environment=FORGEJO__database__DB_TYPE=sqlite3
      Environment=FORGEJO__database__HOST=127.0.0.1:3306
      Environment=FORGEJO__database__NAME=forgejo
      Environment=FORGEJO__database__USER=csd4ni3l
      Environment=FORGEJO__database__PASSWD=${config.sops.placeholder."forgejo-user-password"}
      Environment=FORGEJO__database__PATH=/data/forgejo.db

      Environment=FORGEJO__server__SSH_DOMAIN=${config.sops.placeholder."forgejo-domain"}
      Environment=FORGEJO__server__DOMAIN=${config.sops.placeholder."forgejo-domain"}
      Environment=FORGEJO__server__HTTP_PORT=3000
      Environment=FORGEJO__server__ROOT_URL=https://${config.sops.placeholder."forgejo-domain"}
      Environment=FORGEJO__server__SSH_PORT=22
      Environment=FORGEJO__server__LFS_START_SERVER=true
      Environment=FORGEJO__server__LFS_JWT_SECRET=${config.sops.placeholder."forgejo-lfs-jwt-secret"}
      Environment=FORGEJO__server__OFFLINE_MODE=true

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

      Environment=FORGEJO__openid__ENABLE_OPENID_SIGNIN=false
      Environment=FORGEJO__openid__ENABLE_OPENID_SIGNUP=false
      Environment=FORGEJO__packages__ENABLED=true
      Environment=FORGEJO__oauth2__ENABLED=false
      Environment=FORGEJO__server__DISABLE_SSH=true
      Environment=FORGEJO__mailer__ENABLED=false

      PublishPort=127.0.0.1:59001:3000

      Volume=%h/containers/forgejo/data:/data:Z
      Volume=/etc/localtime:/etc/localtime:ro

      [Install]
      WantedBy=default.target

      [Service]
      Restart=always
    '';
  };
}
