{ pkgs, ... }: {
  xdg.configFile."noctalia".source = ./cfg/noctalia;
  xdg.configFile."niri".source = ./cfg/niri;

  programs.noctalia = {
    enable = true;
  };
}
