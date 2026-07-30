{self, ...}: {
  flake.nixosModules.vramMgmt = {
    pkgs,
    inputs,
    lib,
    config,
    ...
  }: let
    dmemcg-booster = inputs.jovian-nixos.legacyPackages.${pkgs.system}.dmemcg-booster;
  in {
    environment.systemPackages = [dmemcg-booster];

    systemd.packages = [dmemcg-booster];

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
