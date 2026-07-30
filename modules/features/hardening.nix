{self, ...}: {
  flake.nixosModules.hardening = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      ./hardening/_nosuid.nix
      ./hardening/_services.nix
      ./hardening/_blacklist.nix
      ./hardening/_misc.nix
      ./hardening/_sysctl.nix
    ];
  };
}
