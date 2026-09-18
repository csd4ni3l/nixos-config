{self, ...}: {
  flake.nixosModules.AnotherPublicVMSops = {lib, ...}: {
    sops.defaultSopsFile = ./secrets/user.yml;
  };
}
