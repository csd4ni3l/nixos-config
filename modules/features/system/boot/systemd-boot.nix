{...}: {
  flake.nixosModules.systemd-boot = {pkgs, ...}: {
    boot.loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
      };
    };
  };
}
