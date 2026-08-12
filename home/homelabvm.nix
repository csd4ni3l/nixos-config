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

  nixcfgs = nixcfgs;
}
