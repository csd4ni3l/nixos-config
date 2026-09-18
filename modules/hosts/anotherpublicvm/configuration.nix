{self, ...}: {
  flake.nixosModules.AnotherPublicVMConfiguration = {
    lib,
    pkgs,
    ...
  }: {
    imports = [
      # general stuff
      self.nixosModules.options
      self.nixosModules.general
      self.nixosModules.users
      self.nixosModules.impermanence
      self.nixosModules.systemd-boot
      self.nixosModules.networking
      self.nixosModules.dnscrypt
      self.nixosModules.zram
      self.nixosModules.podman
      self.nixosModules.ssh
      self.nixosModules.sops
      self.nixosModules.wings
      self.nixosModules.forgejo-runner

      # hardening
      self.nixosModules.HardeningKernel
      self.nixosModules.HardeningEnvironmentLockdown
      self.nixosModules.HardeningMisc
      self.nixosModules.HardeningNoSUID
      self.nixosModules.HardeningPolkitNoSUID
      self.nixosModules.HardeningServices
      self.nixosModules.HardeningSysCtl

      # host stuff
      self.nixosModules.AnotherPublicVMBoot
      self.nixosModules.AnotherPublicVMDisko
      self.nixosModules.AnotherPublicVMSops
    ];

    nixpkgs.hostPlatform = "x86_64-linux";

    console.keyMap = "hu";
    networking.hostName = "another-public-vm";

    # only guest here because of convention
    users.users.guest = {
      isNormalUser = true;
      description = "untrusted unprivileged container runtime user";
      uid = 1002;
      extraGroups = [];
      shell = pkgs.zsh;
      linger = true;
    };

    environment.persistence."/persist/wings" = {
      hideMounts = true;
      directories = [
        {
          directory = "/var/lib/pelican";
          user = "guest";
          group = "users";
          mode = "0700";
        }
        {
          directory = "/var/log/pelican";
          user = "guest";
          group = "users";
          mode = "0750";
        }
      ];
    };

    environment.persistence."/persist/forgejo-runner" = {
      hideMounts = true;
      directories = [
        {
          directory = "/var/lib/forgejo-runner";
          user = "guest";
          group = "users";
          mode = "0700";
        }
      ];
    };

    systemd.targets.network-online.wantedBy = ["multi-user.target"];

    services.qemuGuest.enable = true;

    nixcfgs = {
      username = "user";
      kernel_module_lock = true;
    };

    home-manager.users."user" = import ../../../home/anotherpublicvm.nix;
    home-manager.users."guest" = import ../../../home/guest-anotherpublicvm.nix;
  };
}
