# NOTE: these were running as untrusted podman workloads that used the podman socket directly,
# so they ran under a separate unprivileged (guest) user for maximum security.
# They are now native systemd services running as the guest user.
{self, ...}: {
  home.username = "guest";
  home.homeDirectory = "/home/guest";

  imports = [
    self.homeModules.options
    ./modules/common/default.nix
    ./modules/server/base.nix
  ];

  sops.defaultSopsFile = ../modules/hosts/publicvm/secrets/guest.yml;
}
