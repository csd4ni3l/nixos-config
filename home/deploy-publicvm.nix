{self, ...}: {
  home.username = "deploy";
  home.homeDirectory = "/home/deploy";

  imports = [
    self.homeModules.options
    ./modules/common/default.nix
    ./modules/server/base.nix

    ./modules/server/containers/newt.nix

    ./modules/server/containers/forgejo.nix
    ./modules/server/containers/pelican-panel.nix
    ./modules/server/containers/website.nix
    ./modules/server/containers/privatebin.nix
    ./modules/server/containers/navidrome.nix
  ];

  sops.defaultSopsFile = ../modules/hosts/publicvm/secrets/deploy.yml;
}
