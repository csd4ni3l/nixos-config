{self, ...}: {
  flake.nixosModules.general = {
    pkgs, config, ...
  }: {

    users.users.csd4ni3l = {
      isNormalUser = true;
      description = "me";
      extraGroups = ["wheel", "networkmanager", "libvirtd"];
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
