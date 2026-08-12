{...}: {
  flake.nixosModules.podman = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [docker-compose passt];
    virtualisation = {
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
