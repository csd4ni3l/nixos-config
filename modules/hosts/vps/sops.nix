{self, ...}: {
  flake.nixosModules.VPSSops = {lib, ...}: {
    sops.defaultSopsFile = ./secrets/user.yml;
  };
}
