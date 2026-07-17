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

    users.users.csd4ni3l = {
      isNormalUser = true;
      description = "me";
      extraGroups = ["wheel" "networkmanager" "libvirtd"];
      shell = pkgs.zsh;
    };

    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit inputs; };

    home-manager.users.csd4ni3l = import ../../home/default.nix;
  };
}
