{...}: {
  flake.nixosModules.virtualisation = {config, ...}: {
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = ["${config.nixcfgs.username}"];
    virtualisation = {
      libvirtd.enable = true;
      podman.enable = true;
    };
  };
}
