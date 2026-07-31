{self, ...}: {
  flake.nixosModules.template = {
    pkgs,
    inputs,
    ...
  }: {
    # something
  };
}
