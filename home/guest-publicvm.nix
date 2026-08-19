# NOTE: these use the podman socket itself and run untrusted workloads, so they need a different user for maximum security
{self, ...}: {
  home.username = "guest";
  home.homeDirectory = "/home/guest";

  imports = [
    self.homeModules.options
    ./modules/common/default.nix
    ./modules/server/base.nix

    ./modules/server/containers/forgejo-runner.nix
    ./modules/server/containers/pelican-wings.nix
  ];

  sops.defaultSopsFile = ../modules/hosts/publicvm/secrets/guest.yml;
}
