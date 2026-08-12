{self, ...}: {
  flake.nixosModules.HardeningNoSUID = {lib, ...}: {
    security.sudo.enable = false;

    security.run0 = {
      enable = true;
      wheelNeedsPassword = true;
      enableSudoAlias = true;
    };

    security.wrappers = {
      su.setuid = lib.mkForce false;
      newgrp.setuid = lib.mkForce false;
      sg.setuid = lib.mkForce false;
      mount.setuid = lib.mkForce false;
      umount.setuid = lib.mkForce false;

      unix_chkpwd = {
        setuid = lib.mkForce false;
        capabilities = "cap_dac_read_search,cap_audit_write=ep";
      };
    };
  };
}
