{self, ...}: {
  flake.nixosModules.users = {
    pkgs,
    inputs,
    config,
    ...
  }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = {
        inherit inputs self;
        nixcfgs = config.nixcfgs;
      };
    };

    users = {
      users.${config.nixcfgs.username} = {
        isNormalUser = true;
        description = "me";
        extraGroups = ["wheel" "networkmanager"];
        shell = pkgs.zsh;
        hashedPasswordFile = "/persist/etc/secrets/password-hash";
      };

      mutableUsers = false;
    };

    # / is a tmpfs but this adds noexec, mode and uid/guid
    fileSystems."/home/${config.nixcfgs.username}/.cache" = {
      device = "none";
      fsType = "tmpfs";
      options = ["size=4G" "mode=0700" "uid=1000" "gid=100" "noexec" "nodev" "nosuid"];
    };
  };
}
