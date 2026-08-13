{
  inputs,
  config,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];
  sops = {
    age.keyFile = "/persist/home/${config.nixcfgs.username}/.config/sops/age/keys.txt";
    age.sshKeyPaths = [];
  };
}
