{...}: {
  flake.nixosModules.virtualisation = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [docker-compose passt];
    programs.virt-manager.enable = true;
    # NOTE: do not put user in libvirtd group which grants rootful QEMU. Instead, use qemu://session inside virt-manager which is rootless.
    virtualisation = {
      libvirtd.enable = true;
      podman = {
        enable = true;
        extraPackages = [pkgs.passt];
      };
      containers.containersConf.settings.network = {
        default_rootless_network_cmd = "pasta";
      };
    };
  };
}
