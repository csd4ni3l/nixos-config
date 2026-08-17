# NOTE: these use the podman socket itself and run untrusted workloads, so they need a different user for maximum security
{self, ...}: {
  imports = [
    self.homeModules.options
    ./modules/server/base.nix
    ./modules/server/containers/forgejo-runner.nix
    ./modules/server/containers/pelican-wings.nix
  ];

  home.username = "guest";
  home.homeDirectory = "/home/guest";

  sops.age = {
    keyFile = "/persist/home/guest/.config/sops/age/keys.txt";
    sshKeyPaths = [];
  };

  sops.defaultSopsFile = ../modules/hosts/publicvm/secrets/guest.yml;
}
