# even though i dislike running nodejs or any AI heavy app in prod, this is safe because im putting it on the openwebui container network,
# so only openwebui can access it, and im not exposing even just openwebui to the internet
{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops.secrets."navidrome-mcp-navidrome-url" = {};
  sops.secrets."navidrome-mcp-navidrome-username" = {};
  sops.secrets."navidrome-mcp-navidrome-password" = {};
  sops.secrets."navidrome-mcp-authtoken" = {};

  sops.templates."navidrome-mcp-config" = {
    content = ''
      {
        "navidrome": {
          "url": "${config.sops.placeholder."navidrome-mcp-navidrome-url"}",
          "username": "${config.sops.placeholder."navidrome-mcp-navidrome-username"}",
          "password": "${config.sops.placeholder."navidrome-mcp-navidrome-password"}"
        },
        "transport": {
          "type": "http",
          "expose": true,
          "port": 62831,
          "authToken": "${config.sops.placeholder."navidrome-mcp-authtoken"}""
        },
        "webui": {
          "enabled": false,
          "port": 8808,
          "host": null,
          "expose": false,
          "autoOpenBrowser": false,
          "persistAfterMcpExit": false
        }
      }
    '';
  };

  sops.templates."navidrome-mcp-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/navidrome-mcp.container";
    content = ''
      [Unit]
      Description=navidrome-mcp
      After=network-online.target

      [Container]
      ContainerName=navidrome-mcp
      AutoUpdate=registry
      Image=ghcr.io/blakeem/navidrome-mcp:latest

      Network=container:openwebui

      Volume=/home/${config.home.username}/.config/sops-nix/secrets/rendered/navidrome-mcp-config:/config/settings.json:ro

      [Service]
      Restart=on-failure

      [Install]
      WantedBy=default.target
    '';
  };
}
