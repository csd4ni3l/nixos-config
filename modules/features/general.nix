{self, ...}: {
  flake.nixosModules.general = {
    pkgs, lib, inputs, ...
  }: {

    time.timeZone = "Europe/Budapest";
    i18n.defaultLocale = "en_GB.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "hu_HU.UTF-8";
      LC_IDENTIFICATION = "hu_HU.UTF-8";
      LC_MEASUREMENT = "hu_HU.UTF-8";
      LC_MONETARY = "hu_HU.UTF-8";
      LC_NAME = "hu_HU.UTF-8";
      LC_NUMERIC = "hu_HU.UTF-8";
      LC_PAPER = "hu_HU.UTF-8";
      LC_TELEPHONE = "hu_HU.UTF-8";
      LC_TIME = "hu_HU.UTF-8";
    };

    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [ git ];

    users.users.csd4ni3l = {
      isNormalUser = true;
      description = "me";
      extraGroups = ["wheel" "networkmanager"];
      shell = pkgs.zsh;
      hashedPasswordFile = "/persist/etc/secrets/password-hash";
    };

    users.mutableUsers = false;

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      optimise.automatic = true;
    };

    # / is a tmpfs but this adds noexec, mode and uid/guid
    fileSystems."/home/csd4ni3l/.cache" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "size=4G" "mode=0700" "uid=1000" "gid=100" "noexec" "nodev" "nosuid" ];
    };

    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";
    home-manager.extraSpecialArgs = { inherit inputs; };

    home-manager.users.csd4ni3l = import ../../home/default.nix;
  };
}
