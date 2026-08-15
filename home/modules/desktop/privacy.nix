{pkgs, ...}: {
  home.packages = with pkgs; [
    veracrypt
    proton-vpn
    onionshare-gui
  ];
}
