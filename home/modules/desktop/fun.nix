{pkgs, ...}: {
  home.packages = with pkgs; [
    nyancat
    cmatrix
  ];
}
