{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.noctalia.homeModules.default
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ./modules/desktop.nix
    ./modules/development.nix
    ./modules/flatpak.nix
    ./modules/hacking.nix
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/theme.nix
    ./modules/xdg.nix
    ./modules/impermanence.nix
    ./modules/backup.nix
  ];

  home.username = "csd4ni3l";
  home.homeDirectory = "/home/csd4ni3l";
  home.stateVersion = "26.11";

  xdg.configFile."Mangohud/MangoHud.conf".source = ./modules/cfg/mangohud/Mangohud.conf;
}
