{...}: {
  flake.nixosModules.virtualisation = {...}: {
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = ["csd4ni3l"];
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
  };
}
