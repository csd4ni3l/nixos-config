{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops.secrets."vaultwarden-domain" = {};

  sops.templates."vaultwarden-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/vaultwarden.container";
    content = ''
      [Unit]
      Description=Vaultwarden

      [Container]
      AutoUpdate=registry
      Image=docker.io/vaultwarden/server:latest-alpine

      Volume=%h/containers/vaultwarden:/data:Z

      PublishPort=127.0.0.1:51001:80
      Environment=DOMAIN=${config.sops.placeholder."vaultwarden-domain"}
      Environment=SIGNUPS_ALLOWED=false

      [Service]
      Restart=on-failure

      [Install]
      WantedBy=default.target
    '';
  };
}
