{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops.secrets."newt-pangolin-endpoint" = {};
  sops.secrets."newt-id" = {};
  sops.secrets."newt-secret" = {};

  sops.templates."newt-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/newt.container";
    content = ''
      [Unit]
      Description=newt

      [Container]
      ContainerName=newt
      AutoUpdate=registry
      Image=docker.io/fosrl/newt

      Network=host

      Environment=PANGOLIN_ENDPOINT=${config.sops.placeholder."newt-pangolin-endpoint"}
      Environment=NEWT_ID=${config.sops.placeholder."newt-id"}
      Environment=NEWT_SECRET=${config.sops.placeholder."newt-secret"}

      [Service]
      Restart=on-failure

      [Install]
      WantedBy=default.target
    '';
  };
}
