{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  homelab.containerDirs = ["${config.home.homeDirectory}/containers/mariadb"];

  sops.secrets."mariadb-root-password" = {};

  sops.templates."mariadb-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/mariadb.container";
    content = ''
      [Unit]
      Description=MariaDB database server
      Wants=network-online.target
      After=network-online.target

      [Container]
      Image=lscr.io/linuxserver/mariadb
      AutoUpdate=registry
      ContainerName=mariadb
      UserNS=keep-id:uid=1001,gid=100

      Environment=TZ=Europe/Budapest
      Environment=PUID=1001
      Environment=PGID=100

      Environment=MYSQL_ROOT_PASSWORD=${config.sops.placeholder."mariadb-root-password"}

      Volume=${config.home.homeDirectory}/containers/mariadb:/config:Z
      PublishPort=3306:3306

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';
  };
}
