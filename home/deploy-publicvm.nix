{self, ...}: {
  imports = [
    self.homeModules.options
    ./modules/server/base.nix

    ./modules/server/containers/newt.nix

    ./modules/server/containers/forgejo.nix
    ./modules/server/containers/pelican-panel.nix
    ./modules/server/containers/website.nix
    ./modules/server/containers/privatebin.nix
    ./modules/server/containers/navidrome.nix
  ];

  home.username = "deploy";
  home.homeDirectory = "/home/deploy";

  sops.age = {
    keyFile = "/persist/home/deploy/.config/sops/age/keys.txt";
    sshKeyPaths = [];
  };

  sops.defaultSopsFile = ../modules/hosts/publicvm/secrets/deploy.yml;
}
