{
  self,
  nixcfgs,
  config,
  ...
}: {
  home.username = "${config.nixcfgs.username}";
  home.homeDirectory = "/home/${config.nixcfgs.username}";

  imports = [
    self.homeModules.options
    ./modules/common/default.nix
    ./modules/server/impermanence.nix
  ];

  sops.defaultSopsFile = ../modules/hosts/publicvm/secrets/user.yml;

  nixcfgs = nixcfgs;
}
