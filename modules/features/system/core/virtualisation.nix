{...}: {
  flake.nixosModules.virtualisation = {config, ...}: {
    programs.virt-manager.enable = true;
    # NOTE: do not put user in libvirtd group which grants rootful QEMU. Instead, use qemu://session inside virt-manager which is rootless.
    virtualisation = {
      libvirtd.enable = true;
      podman.enable = true;
    };
  };
}
