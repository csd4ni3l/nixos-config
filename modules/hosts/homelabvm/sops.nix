{self, ...}: {
  flake.nixosModules.HomeLabVMSops = {
    lib,
    ...
  }: {
    sops.defaultSopsFile = ./secrets.yml;
  };
}
