{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  homelab.containerDirs = ["${config.home.homeDirectory}/containers/ntfy/data"];

  sops.secrets."ntfy-base-url" = {};

  sops.templates."ntfy-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/ntfy.container";
    content = ''
      [Unit]
      Description=ntfy
      After=network-online.target

      [Container]
      ContainerName=ntfy
      Image=docker.io/binwiederhier/ntfy:v2.29.0

      PublishPort=127.0.0.1:53001:80

      Volume=%h/containers/ntfy/data:/var/lib/ntfy:Z

      Environment=NTFY_BASE_URL=${config.sops.placeholder."ntfy-base-url"}
      Environment=NTFY_LISTEN_HTTP=:80
      Environment=NTFY_BEHIND_PROXY=true
      Environment=NTFY_CACHE_FILE=/var/lib/ntfy/cache.db
      Environment=NTFY_CACHE_DURATION=12h
      Environment=TZ=Europe/Budapest

      [Service]
      Restart=on-failure

      [Install]
      WantedBy=default.target
    '';
  };
}
