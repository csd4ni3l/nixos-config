{self, ...}: {
  flake.nixosModules.tailscale = {
    lib,
    pkgs,
    inputs,
    ...
  }: {
    services.tailscale.enable = true;

    nixcfgs.impermanence.tailscale = lib.mkDefault true;
  };
}
