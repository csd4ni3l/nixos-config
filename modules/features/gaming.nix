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

    environment.systemPackages = with pkgs; [
      protonup-qt
      low-latency-layer
      dxvk
      mangohud
      vulkan-tools
      wine
    ];
  };
}
