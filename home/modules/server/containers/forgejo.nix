{config, ...}: {
  homelab.containerDirs = ["${config.home.homeDirectory}/containers/forgejo/data" "${config.home.homeDirectory}/containers/forgejo/config"];

  sops.secrets."forgejo-user-password" = {};
  sops.secrets."forgejo-domain" = {};
  sops.secrets."forgejo-lfs-jwt-secret" = {};
  sops.secrets."forgejo-internal-token" = {};
  sops.secrets."forgejo-oauth2-secret" = {};

  sops.templates."forgejo-app-ini" = {
    path = "${config.home.homeDirectory}/containers/forgejo/config/app.ini";
    content = ''
      APP_NAME=csd4ni3l Git

      [database]
      DB_TYPE=sqlite3
      HOST=127.0.0.1:3306
      NAME=forgejo
      USER=csd4ni3l
      PASSWD=${config.sops.placeholder."forgejo-user-password"}
      PATH=/var/lib/gitea/forgejo.db

      [server]
      SSH_DOMAIN=${config.sops.placeholder."forgejo-domain"}
      DOMAIN=${config.sops.placeholder."forgejo-domain"}
      HTTP_PORT=3000
      ROOT_URL=https://${config.sops.placeholder."forgejo-domain"}
      SSH_PORT=22
      LFS_START_SERVER=true
      LFS_JWT_SECRET=${config.sops.placeholder."forgejo-lfs-jwt-secret"}
      OFFLINE_MODE=true
      DISABLE_SSH=true

      [service]
      REGISTER_EMAIL_CONFIRM=false
      ENABLE_NOTIFY_MAIL=false
      DISABLE_REGISTRATION=true
      ALLOW_ONLY_EXTERNAL_REGISTRATION=false
      ENABLE_CAPTCHA=true
      REQUIRE_SIGNIN_VIEW=false
      DEFAULT_KEEP_EMAIL_PRIVATE=true
      DEFAULT_ALLOW_CREATE_ORGANIZATION=true
      DEFAULT_ENABLE_TIMETRACKING=true
      NO_REPLY_ADDRESS=noreply.localhost

      [security]
      INSTALL_LOCK=true
      INTERNAL_TOKEN=${config.sops.placeholder."forgejo-internal-token"}
      PASSWORD_HASH_ALGO=pbkdf2_hi

      [oauth2]
      JWT_SECRET=${config.sops.placeholder."forgejo-oauth2-secret"}
      ENABLED=false

      [openid]
      ENABLE_OPENID_SIGNIN=false
      ENABLE_OPENID_SIGNUP=false

      [packages]
      ENABLED=true

      [mailer]
      ENABLED=false
    '';
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

      Volume=%h/containers/forgejo/config:/etc/gitea:Z
      Volume=%h/containers/forgejo/data:/var/lib/gitea:Z
      Volume=/etc/localtime:/etc/localtime:ro

      [Install]
      WantedBy=default.target

      [Service]
      Restart=always
    '';
  };
}
