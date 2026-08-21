{inputs, ...}: {
  flake.nixosModules.impermanence = {...}: {
    imports = [inputs.impermanence.nixosModules.impermanence];
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/etc/ssh"
        "/etc/NetworkManager/system-connections"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/sbctl"
        "/var/lib/tailscale"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
