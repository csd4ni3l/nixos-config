{self, inputs, ...}: {
  flake.nixosModules.hostImpermanence = { pkgs, lib, ... }: {
    imports = [ inputs.impermanence.nixosModules.impermanence ];
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/flatpak"
        "/var/lib/fprintd"
        "/var/lib/sbctl"
        "/etc/nixos"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
