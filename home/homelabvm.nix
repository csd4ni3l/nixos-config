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

  sops.defaultSopsFile = ../modules/hosts/homelabvm/secrets.yml;

  nixcfgs = nixcfgs;
}
