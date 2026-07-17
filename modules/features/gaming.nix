{self, ...}: {
  flake.nixosModules.gaming = {
    pkgs, config, ...
  }: {
    programs = {
      gamescope.enable = true;
      gamemode.enable = true;
      steam = {
        enable = true;
        protontricks.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      dxvk
      mangohud
      vulkan-tools
      wine
    ];
  };
}
