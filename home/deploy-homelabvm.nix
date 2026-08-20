{self, ...}: {
  home.username = "deploy";
  home.homeDirectory = "/home/deploy";

  imports = [
    self.homeModules.options
    ./modules/common/default.nix
    ./modules/server/base.nix

    ./modules/server/containers/nginx-proxy-manager.nix
    ./modules/server/containers/vikunja.nix
    ./modules/server/containers/aonsoku.nix
    ./modules/server/containers/freshrss.nix
    ./modules/server/containers/ittools.nix
    ./modules/server/containers/vaultwarden.nix
    ./modules/server/containers/navidrome.nix
  ];

  sops.defaultSopsFile = ../modules/hosts/homelabvm/secrets/deploy.yml;
}
