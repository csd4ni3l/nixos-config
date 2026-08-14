# NOTE: doesn't work yet
{
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  home.file = {
    "containers/wyzebridge/config/.keep".text = "";
    "containers/wyzebridge/media/.keep".text = "";
  };

  sops.secrets."wyzebridge-email" = {};
  sops.secrets."wyzebridge-password" = {};
  sops.secrets."wyzebridge-api-id" = {};
  sops.secrets."wyzebridge-api-key" = {};
  sops.secrets."wyzebridge-camera-name" = {};

  sops.templates."wyzebridge-container" = {
    path = "${config.home.homeDirectory}/.config/containers/systemd/wyzebridge.container";
    content = ''
      [Unit]
      Description=WyzeBridge

      [Container]
      AutoUpdate=registry
      Image=docker.io/idisposablegithub365/wyze-bridge:latest

      Volume=%h/containers/wyzebridge/config:/config:Z
      Volume=%h/containers/wyzebridge/media:/media:Z

      PublishPort=127.0.0.1:50001:5080
      PublishPort=127.0.0.1:50002:8554
      PublishPort=127.0.0.1:50003:8888
      PublishPort=127.0.0.1:50004:8889
      PublishPort=127.0.0.1:50005:8189/udp

      AddDevice=/dev/dri/renderD128

      Environment=WYZE_EMAIL=${config.sops.placeholder."wyzebridge-email"}
      Environment=WYZE_PASSWORD=${config.sops.placeholder."wyzebridge-password"}
      Environment=QUALITY_${config.sops.placeholder."wyzebridge-camera-name"}=hd
      Environment=AUDIO_${config.sops.placeholder."wyzebridge-camera-name"}=false
      Environment=RECORDING_${config.sops.placeholder."wyzebridge-camera-name"}=false
      Environment=H264_ENC=h264_preset-vaapi
      Environment=API_ID=${config.sops.placeholder."wyzebridge-api-id"}
      Environment=API_KEY=${config.sops.placeholder."wyzebridge-api-key"}

      [Service]
      Restart=on-failure
    '';
  };
}
