{self, ...}: {
  flake.nixosModules.tailscale = {
    lib,
    pkgs,
    inputs,
    ...
  }: {
    services.tailscale = {
      enable = true;
      disableTaildrop = true;
      disableUpstreamLogging = true;
      serve.enable = false;
      derper.enable = false;
    };

    nixcfgs.impermanence.tailscale = lib.mkDefault true;
  };
}
