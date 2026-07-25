{self, ...}: {
  flake.nixosModules.gaming = {
    pkgs, inputs, lib, ...
  }: {

    nixpkgs.overlays = [
      inputs.chaotic.overlays.default
    ];

    programs = {
      gamescope.enable = true;
      gamemode.enable = true;
      steam = {
        enable = true;
        protontricks.enable = true;
      };
    };

    boot.kernelModules = [ "ntsync" ];

    environment.systemPackages = with pkgs; [
      protonplus
      low-latency-layer
      dxvk
      mangohud
      vulkan-tools
      wine
    ];
  };
}
