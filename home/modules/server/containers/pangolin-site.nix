{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops.secrets."newt-pangolin-endpoint" = {};
  sops.secrets."newt-id" = {};
  sops.secrets."newt-secret" = {};

  sops.templates."pangolin-site-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/pangolin-site.container";
    content = ''
      [Unit]
      Description=Pangolin Site
      After=network-online.target

      [Container]
      ContainerName=pangolin-site
      AutoUpdate=registry
      Image=docker.io/fosrl/pangolin-cli

      Network=host

      Environment=PANGOLIN_ENDPOINT=${config.sops.placeholder."newt-pangolin-endpoint"}
      Environment=SITE_ID=${config.sops.placeholder."newt-id"}
      Environment=SITE_SECRET=${config.sops.placeholder."newt-secret"}
      Environment=HEALTH_FILE=/tmp/healthy

      HealthCmd=test -f /tmp/healthy
      HealthInterval=30s
      HealthRetries=3
      HealthStartPeriod=30s
      HealthTimeout=5s

      [Service]
      Restart=always

      [Install]
      WantedBy=default.target
    '';
  };
}
