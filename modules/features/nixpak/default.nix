{self, ...}: {
  flake.nixosModules.nixpak = {
    pkgs,
    inputs,
    ...
  }: {
    imports = [inputs.nixpak.nixosModules.default];
    security.nixpak.enable = true;
  };
}
