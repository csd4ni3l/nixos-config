{...}: {
  imports = [
    ./cli.nix
    ./sops.nix
    ./envlockdown.nix
  ];
  home.stateVersion = "26.11";
}
