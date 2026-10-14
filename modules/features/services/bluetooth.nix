{lib, ...}: {
  flake.nixosModules.bluetooth = {lib, ...}: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
    };

    nixcfgs.impermanence.bluetooth = lib.mkDefault true;
  };
}
