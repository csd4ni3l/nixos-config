{config, ...}: {
  imports = [
    ./cli.nix
    ./sops.nix
  ];

  home.username = "${config.nixcfgs.username}";
  home.homeDirectory = "/home/${config.nixcfgs.username}";
  home.stateVersion = "26.11";
}
