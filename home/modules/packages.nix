{ pkgs, ... }: {
  programs.mpv = {
    enable = true;
    config = {
      profile = "high-quality";
      ytdl-format = "bestvideo+bestaudio";
      cache-default = 4000000;
    };
  };

  home.packages = with pkgs; [
    # apps
    orca-slicer
    veracrypt
    proton-vpn
    firefox
    jrnl

    # other
    udiskie
    baobab
    proxmox-backup-client
  ];
}
