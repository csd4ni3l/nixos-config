{inputs, ...}: {
  flake.nixosModules.impermanence = {...}: {
    imports = [inputs.impermanence.nixosModules.impermanence];
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/sbctl"
        "/var/lib/tailscale"
        "/var/lib/crowdsec"
        "/var/lib/crowdsec-firewall-bouncer-register"
      ];
      files = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
  };
}
