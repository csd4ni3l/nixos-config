{self, ...}: {
  home.username = "deploy";
  home.homeDirectory = "/home/deploy";

  imports = [
    self.homeModules.options
    ./modules/common/default.nix
    ./modules/server/base.nix

    ./modules/server/containers/pangolin.nix
    ./modules/server/containers/mariadb.nix
  ];

  sops.defaultSopsFile = ../modules/hosts/vps/secrets/deploy.yml;
}
