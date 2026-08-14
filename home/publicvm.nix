{
  self,
  nixcfgs,
  ...
}: {
  imports = [
    self.homeModules.options
    ./modules/common/default.nix
    ./modules/server/impermanence.nix
  ];

  sops.defaultSopsFile = ../modules/hosts/publicvm/secrets.yml;

  nixcfgs = nixcfgs;
}
