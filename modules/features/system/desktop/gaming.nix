{self, ...}: {
  flake.nixosModules.gaming = {
    pkgs,
    inputs,
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
      self.packages.${pkgs.system}.dmemcg-booster
    ];

    systemd.packages = [self.packages.${pkgs.system}.dmemcg-booster];

    systemd.services.dmemcg-booster-system = {
      overrideStrategy = "asDropin";
      wantedBy = ["multi-user.target"];
    };

    systemd.user.services.dmemcg-booster-user = {
      overrideStrategy = "asDropin";
      wantedBy = ["graphical-session-pre.target"];
    };
  };
}
