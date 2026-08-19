{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops.secrets."vikunja-domain" = {};

  homelab.containerDirs = ["${config.home.homeDirectory}/containers/vikunja/db" "${config.home.homeDirectory}/containers/vikunja/files"];

  sops.templates."vikunja-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/vikunja.container";
    content = ''
      [Unit]
      Description=Vikunja container
      After=network-online.target

      [Container]
      ContainerName=vikunja
      AutoUpdate=registry
      Image=docker.io/vikunja/vikunja
      UserNS=keep-id:uid=1000,gid=0

      PublishPort=127.0.0.1:61000:3456

      Environment=VIKUNJA_DATABASE_PATH=/db/vikunja.db
      Environment=VIKUNJA_SERVICE_PUBLICURL=${config.sops.placeholder."vikunja-domain"}

      Volume=%h/containers/vikunja/files:/app/vikunja/files
      Volume=%h/containers/vikunja/db:/db

      [Install]
      WantedBy=default.target

      [Service]
      Restart=always
    '';
  };
}
