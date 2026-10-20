{
  ...
}: {
  # NOTE: enable use of A2DP (buttons on headsets) with the MPRIS dbus standard
  services.mpris-proxy.enable = true;

  programs.dank-material-shell = {
    enable = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableSystemMonitoring = true;
    enableVPN = true;
    enableAudioWavelength = true;
  };
}
