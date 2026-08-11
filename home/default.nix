{
  self,
  inputs,
  config,
  nixcfgs,
  ...
}: {
  imports = [
    inputs.noctalia.homeModules.default
    self.homeModules.options
    ./modules/desktop.nix
    ./modules/development.nix
    ./modules/hacking.nix
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/theme.nix
    ./modules/xdg.nix
    ./modules/impermanence.nix
    ./modules/backup.nix
    ./modules/fun.nix
    ./modules/browsing.nix
  ];

  nixcfgs = nixcfgs;

  home.username = "${config.nixcfgs.username}";
  home.homeDirectory = "/home/${config.nixcfgs.username}";
  home.stateVersion = "26.11";

  xdg.configFile."Mangohud/MangoHud.conf".source = ./modules/cfg/mangohud/Mangohud.conf;
}
