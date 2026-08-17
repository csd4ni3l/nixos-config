{self, ...}: {
  flake.nixosModules.PublicVMSops = {lib, ...}: {
    sops.defaultSopsFile = ./secrets/user.yml;
  };
}
