{self, ...}: {
  flake.nixosModules.HardeningPolkitNoSUID = {lib, ...}: {
    security.wrappers.pkexec.setuid = lib.mkForce false;
  };
}
