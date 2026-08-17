{
  self,
  nixcfgs,
  ...
}: {
  imports = [
    self.homeModules.options
    ./modules/common/default.nix
    ./modules/server/impermanence.nix
  ];

  sops.age = {
    keyFile = "/persist/home/user/.config/sops/age/keys.txt";
    sshKeyPaths = [];
  };

  sops.defaultSopsFile = ../modules/hosts/homelabvm/secrets/user.yml;

  nixcfgs = nixcfgs;
}
