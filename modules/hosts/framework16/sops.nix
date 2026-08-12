{self, ...}: {
  flake.nixosModules.Framework16Sops = {
    lib,
    ...
  }: {
    sops.defaultSopsFile = ./secrets.yml;
  };
}
