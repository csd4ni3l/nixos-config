{...}: {
  flake.nixosModules.limine = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.sbctl
    ];

    boot.loader.limine = {
      enable = true;
      secureBoot.enable = true;
      enrollConfig = true;
      validateChecksums = true;
      panicOnChecksumMismatch = true;
    };
  };
}
