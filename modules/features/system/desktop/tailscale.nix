{self, ...}: {
  flake.nixosModules.tailscale = {
    pkgs,
    inputs,
    ...
  }: {
    services.tailscale.enable = true;
  };
}
