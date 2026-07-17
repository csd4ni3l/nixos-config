{
  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs:nixos-unstable";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-cli/flake-parts";
    import-tree.url = "github:vic/import-tree";

    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake
    {inherit inputs;}
    {inputs.import-tree ./modules};

}
