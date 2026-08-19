{...}: {
  home.file.".config/containers/systemd/aonsoku.container".text = ''
    [Unit]
    Description=Aonsoku Container
    After=network-online.target

    [Container]
    ContainerName=aonsoku
    Image=ghcr.io/victoralvesf/aonsoku:latest
    PublishPort=127.0.0.1:60001:8080
    AutoUpdate=registry
    Network=navidrome.network
    Environment=HIDE_SERVER=true
    Environment=SERVER_TYPE=navidrome
    Environment=HIDE_RADIOS_SECTION=true
    Environment=APP_THEME=catpuccin-mocha
    Environment=IMAGE_CACHE_ENABLED=true
    Environment=SERVER_URL=http://navidrome:4533

    [Service]
    Restart=always

    [Install]
    WantedBy=default.target
  '';
}
