{...}: {
  flake.nixosModules.wings = {
    config,
    pkgs,
    ...
  }: {
    systemd.tmpfiles.rules = [
      "d /var/lib/pelican 0700 guest users -"
      "d /var/lib/pelican/volumes 0700 guest users -"
      "d /var/lib/pelican/archives 0700 guest users -"
      "d /var/lib/pelican/backups 0700 guest users -"
      "d /var/lib/pelican/machine-id 0700 guest users -"
      "d /var/log/pelican 0750 guest users -"
      "d /etc/pelican 0700 guest users -"
    ];
  };
}
