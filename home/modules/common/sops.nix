{
  inputs,
  config,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];
  sops = {
    age.keyFile = "/persist/home/${config.home.username}/.config/sops/age/keys.txt";
    age.sshKeyPaths = [];
  };
}
