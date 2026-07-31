{pkgs, ...}: {
  xdg.configFile."noctalia".source = ./cfg/noctalia;
  xdg.configFile."niri".source = ./cfg/niri;

  # NOTE: enable use of A2DP (buttons on headsets) with the MPRIS dbus standard
  services.mpris-proxy.enable = true;

  programs.noctalia = {
    enable = true;
  };
}
