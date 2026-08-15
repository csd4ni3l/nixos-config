{pkgs, ...}: {
  home.packages = with pkgs; [
    veracrypt
    proton-vpn
    onionshare
    mat2
  ];
}
