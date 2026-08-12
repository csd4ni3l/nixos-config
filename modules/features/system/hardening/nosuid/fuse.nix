{self, ...}: {
  flake.nixosModules.HardeningFUSENoSUID = {lib, ...}: {
    security.wrappers = {
      fusermount3 = {
        setuid = lib.mkForce false;
        capabilities = "cap_sys_admin=ep";
      };

      fusermount = {
        setuid = lib.mkForce false;
        capabilities = "cap_sys_admin=ep";
      };
    };
  };
}
