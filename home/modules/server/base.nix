{
  inputs,
  config,
  lib,
  ...
}: {
  options.homelab.containerDirs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = ''
      Container data directories (absolute paths) to pre-create before
      podman quadlets start, instead of placing .keep marker files inside
      the container volumes.
    '';
  };

  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./impermanence.nix
  ];

  config = {
    home.activation.createContainerDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${lib.concatMapStringsSep "\n" (d: "mkdir -p '${d}'") config.homelab.containerDirs}
    '';

    home.username = "deploy";
    home.homeDirectory = "/home/deploy";
    home.stateVersion = "26.11";

    sops.age = {
      keyFile = "/persist/home/deploy/.config/sops/age/keys.txt";
      sshKeyPaths = [];
    };
  };
}
