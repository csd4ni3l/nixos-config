{inputs, ...}: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./impermanence.nix
  ];

  home.username = "deploy";
  home.homeDirectory = "/home/deploy";
  home.stateVersion = "26.11";

  sops.age = {
    keyFile = "/persist/home/deploy/.config/sops/age/keys.txt";
    sshKeyPaths = [];
  };
}
