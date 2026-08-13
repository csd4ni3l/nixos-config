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
    ./modules/server/containers/nginx-proxy-manager.nix

    ./modules/server/containers/aonsoku.nix
    ./modules/server/containers/freshrss.nix
    ./modules/server/containers/ittools.nix
    ./modules/server/containers/piped.nix
    ./modules/server/containers/vaultwarden.nix
    ./modules/server/containers/wyzebridge.nix
  ];

  sops.defaultSopsFile = ../modules/hosts/homelabvm/secrets.yml;

  nixcfgs = nixcfgs;
}
