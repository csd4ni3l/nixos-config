{self, ...}: {
  flake.nixosModules.sops = {
    pkgs,
    inputs,
    config,
    ...
  }: {
    imports = [inputs.sops-nix.nixosModules.sops];

    sops = {
      age = {
        keyFile = "/home/${config.nixcfgs.username}/.config/sops/age/keys.txt";
        sshKeyPaths = [];
      };

      secrets."password-hash" = {
        neededForUsers = true;
        path = "/persist/etc/secrets/password-hash";
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    environment.systemPackages = with pkgs; [sops age];
  };
}
