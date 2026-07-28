{ pkgs, lib, ... }: {
  fileSystems."/proc" = {
    device = "proc";
    fsType = "proc";
    options = [ "hidepid=2" "gid=42" ];
  };

  security.sudo.enable = false;

  security.run0 = {
    enable = true;
    wheelNeedsPassword = true;
    enableSudoAlias = true;
  };

  security.wrappers = {
    pkexec.setuid = lib.mkForce false;
    su.setuid = lib.mkForce false;
    newgrp.setuid = lib.mkForce false;
    sg.setuid = lib.mkForce false;
    mount.setuid = lib.mkForce false;
    umount.setuid = lib.mkForce false;
    qemu-bridge-helper.setuid = lib.mkForce false;

    fusermount3 = {
      setuid = lib.mkForce false;
      capabilities = "cap_sys_admin=ep";
    };

    fusermount = {
      setuid = lib.mkForce false;
      capabilities = "cap_sys_admin=ep";
    };

    unix_chkpwd = {
      setuid = lib.mkForce false;
      capabilities = "cap_dac_read_search,cap_audit_write=ep";
    };
  };
}
