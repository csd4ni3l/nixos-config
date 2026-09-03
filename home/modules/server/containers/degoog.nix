{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  homelab.containerDirs = ["${config.home.homeDirectory}/containers/degoog"];

  sops.secrets."degoog-settings-password" = {};

  sops.templates."degoog-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/degoog.container";
    content = ''
      [Unit]
      Description=Degoog selfhosted search aggregator
      Wants=network-online.target
      After=network-online.target

      [Container]
      Image=ghcr.io/degoog-org/degoog:latest
      AutoUpdate=registry
      ContainerName=degoog
      Environment=TZ=Europe/Budapest
      Environment=PUID=1001
      Environment=PGID=100
      Environment=DEGOOG_SETTINGS_PASSWORDS=${config.sops.placeholder."degoog-settings-password"}
      UIDMap=+%U:@%U
      Volume=${config.home.homeDirectory}/containers/degoog:/app/data:Z
      PublishPort=65001:4444

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';
  };
}
