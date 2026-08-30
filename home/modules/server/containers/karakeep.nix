{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  homelab.containerDirs = [
    "${config.home.homeDirectory}/containers/karakeep/data"
    "${config.home.homeDirectory}/containers/karakeep/meilisearch"
  ];

  sops.secrets."karakeep-nextauth-secret" = {};
  sops.secrets."karakeep-meili-master-key" = {};
  sops.secrets."karakeep-openai-api-key" = {};

  sops.templates."karakeep-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/karakeep.container";
    content = ''
      [Unit]
      Description=Karakeep
      After=network-online.target

      [Container]
      ContainerName=karakeep
      AutoUpdate=registry
      Image=ghcr.io/karakeep-app/karakeep:release

      Network=karakeep.network

      PublishPort=127.0.0.1:63001:3000

      Volume=%h/containers/karakeep/data:/data:Z

      Environment=DATA_DIR=/data
      Environment=MEILI_ADDR=http://karakeep-meilisearch:7700
      Environment=BROWSER_WEB_URL=http://karakeep-chrome:9222
      Environment=NEXTAUTH_SECRET=${config.sops.placeholder."karakeep-nextauth-secret"}
      Environment=NEXTAUTH_URL=http://localhost:3000
      Environment=MEILI_MASTER_KEY=${config.sops.placeholder."karakeep-meili-master-key"}

      Environment=OPENAI_BASE_URL=https://openrouter.ai/api/v1
      Environment=OPENAI_API_KEY=${config.sops.placeholder."karakeep-openai-api-key"}
      Environment=INFERENCE_TEXT_MODEL=deepseek/deepseek-v4-flash-0731
      Environment=INFERENCE_IMAGE_MODEL=qwen/qwen3.8-flash
      Environment=EMBEDDING_TEXT_MODEL=qwen/qwen3-embedding-8b
      Environment=EMBEDDING_DIMENSIONS=4096
      Environment=EMBEDDING_ENABLE_AUTO_INDEXING=true

      [Service]
      Restart=on-failure

      [Install]
      WantedBy=default.target
    '';
  };

  sops.templates."karakeep-meilisearch-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/karakeep-meilisearch.container";
    content = ''
      [Unit]
      Description=Karakeep Meilisearch
      After=network-online.target

      [Container]
      ContainerName=karakeep-meilisearch
      AutoUpdate=registry
      Image=docker.io/getmeili/meilisearch:v1.41.0

      Network=karakeep.network

      Volume=%h/containers/karakeep/meilisearch:/meili_data:Z

      Environment=MEILI_NO_ANALYTICS=true
      Environment=MEILI_MASTER_KEY=${config.sops.placeholder."karakeep-meili-master-key"}

      [Service]
      Restart=on-failure

      [Install]
      WantedBy=default.target
    '';
  };

  home.file = {
    ".config/containers/systemd/karakeep.network".text = ''
      [Network]
      NetworkName=karakeep
    '';

    ".config/containers/systemd/karakeep-chrome.container".text = ''
      [Unit]
      Description=Karakeep Chrome
      After=network-online.target

      [Container]
      ContainerName=karakeep-chrome
      AutoUpdate=registry
      Image=ghcr.io/karakeep-app/karakeep-chrome:release

      Network=karakeep.network

      Exec=--disable-gpu --disable-dev-shm-usage --hide-scrollbars --disable-blink-features=AutomationControlled --window-size=1440,900

      [Service]
      Restart=on-failure

      [Install]
      WantedBy=default.target
    '';
  };
}
