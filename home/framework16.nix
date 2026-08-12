{
  self,
  inputs,
  nixcfgs,
  ...
}: {
  imports = [
    inputs.noctalia.homeModules.default
    self.homeModules.options
    ./modules/common/default.nix
    ./modules/desktop/desktop.nix
    ./modules/desktop/development.nix
    ./modules/desktop/hacking.nix
    ./modules/desktop/packages.nix
    ./modules/desktop/shell.nix
    ./modules/desktop/theme.nix
    ./modules/desktop/xdg.nix
    ./modules/desktop/impermanence.nix
    ./modules/desktop/backup.nix
    ./modules/desktop/fun.nix
    ./modules/desktop/browsing.nix
  ];

  nixcfgs = nixcfgs;

  sops.defaultSopsFile = ../modules/hosts/framework16/secrets.yml;

  xdg.configFile."Mangohud/MangoHud.conf".source = ./modules/desktop/cfg/mangohud/Mangohud.conf;
}
