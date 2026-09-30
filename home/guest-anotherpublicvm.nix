# NOTE: guest is the user that has access to a rootless podman socket, and runs untrusted workloads, so it is separated from deploy for security
# normally, guest would not run the pangolin site connector, but i dont want to use the deploy user just for it here
{self, ...}: {
  home.username = "guest";
  home.homeDirectory = "/home/guest";

  imports = [
    self.homeModules.options
    ./modules/common/default.nix
    ./modules/server/base.nix
    ./modules/server/containers/pangolin-site.nix
    ./modules/server/services/forgejo-runner.nix
    ./modules/server/services/wings.nix
  ];

  sops.defaultSopsFile = ../modules/hosts/anotherpublicvm/secrets/guest.yml;
}
