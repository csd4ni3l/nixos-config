{...}: {
  flake.nixosModules.virt-manager = {pkgs, ...}: {
    # NOTE: do not put user in libvirtd group which grants rootful QEMU. Instead, use qemu://session inside virt-manager which is rootless.
    programs.virt-manager.enable = true;
    virtualisation.libvirtd.enable = true;
  };
}
