{self, ...}: {
  flake.nixosModules.HardeningQEMUNoSUID = {lib, ...}: {
    security.wrappers.qemu-bridge-helper.setuid = lib.mkForce false;
  };
}
