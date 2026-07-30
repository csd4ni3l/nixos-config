{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.hostImpermanence = {
    pkgs,
    lib,
    ...
  }: {
    imports = [inputs.impermanence.nixosModules.impermanence];
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/flatpak"
        "/var/lib/sbctl"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
