{
  inputs,
  ...
}: {
  flake.nixosModules.impermanence = {
    lib,
    config,
    ...
  }: {
    imports = [inputs.impermanence.nixosModules.impermanence];

    environment.persistence."/persist" = lib.mkMerge [
      {
        hideMounts = true;
        directories = [
          "/var/lib/nixos"
        ];
        files = [
          "/etc/machine-id"
        ];
      }

      (lib.mkIf config.nixcfgs.impermanence.networking {
        directories = [
          "/etc/NetworkManager/system-connections"
        ];
      })

      (lib.mkIf config.nixcfgs.impermanence.bluetooth {
        directories = [
          "/var/lib/bluetooth"
        ];
      })

      (lib.mkIf config.nixcfgs.impermanence.tailscale {
        directories = [
          "/var/lib/tailscale"
        ];
      })

      (lib.mkIf config.nixcfgs.impermanence.limine {
        directories = [
          "/var/lib/sbctl"
        ];
      })

      (lib.mkIf config.nixcfgs.impermanence.ssh {
        files = [
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];
      })
    ];
  };
}
