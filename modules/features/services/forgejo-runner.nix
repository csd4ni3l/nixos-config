{...}: {
  flake.nixosModules.forgejo-runner = {
    config,
    pkgs,
    ...
  }: {
    systemd.tmpfiles.rules = [
      "d /var/lib/forgejo-runner 0700 guest users -"
      "d /var/lib/forgejo-runner/workdir 0700 guest users -"
    ];
  };
}
