{self, ...}: {
  flake.nixosModules.gaming = {
    pkgs,
    inputs,
    lib,
    ...
  }: {
    programs = {
      gamescope.enable = true;
      gamemode.enable = true;
      steam = {
        enable = true;
        protontricks.enable = true;
      };
    };

    boot.kernelModules = ["ntsync"];

    environment.systemPackages = with pkgs; [
      amdgpu_top
      protonplus
      dxvk
      mangohud
      vulkan-tools
      wine
    ];
  };
}
