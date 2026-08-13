{
  self,
  nixcfgs,
  ...
}: {
  imports = [
    self.homeModules.options
    ./modules/common/default.nix
    ./modules/server/impermanence.nix
    ./modules/server/quadlet.nix

    ./modules/server/containers/newt.nix

    ./modules/server/containers/forgejo.nix
    ./modules/server/containers/forgejo-runner.nix

    ./modules/server/containers/pelican-panel.nix
    ./modules/server/containers/pelican-wings.nix

    ./modules/server/containers/privatebin.nix
    ./modules/server/containers/navidrome.nix
  ];

  sops.defaultSopsFile = ../modules/hosts/publicvm/secrets.yml;

  nixcfgs = nixcfgs;
}
