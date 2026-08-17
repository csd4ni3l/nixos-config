{self, ...}: {
  flake.nixosModules.HomeLabVMSops = {lib, ...}: {
    sops.defaultSopsFile = ./secrets/user.yml;
  };
}
