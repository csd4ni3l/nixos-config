{self, ...}: {
  flake.nixosModules.HomeLabVMConfiguration = {lib, ...}: {
    imports = [
      # general stuff
      self.nixosModules.options
      self.nixosModules.general
      self.nixosModules.users
      self.nixosModules.impermanence
      self.nixosModules.systemd-boot
      self.nixosModules.networking
      self.nixosModules.zram
      self.nixosModules.podman
      self.nixosModules.ssh
      self.nixosModules.sops

      # hardening
      self.nixosModules.HardeningKernel
      self.nixosModules.HardeningMisc
      self.nixosModules.HardeningNoSUID
      self.nixosModules.HardeningPolkitNoSUID
      self.nixosModules.HardeningServices
      self.nixosModules.HardeningSysCtl

      # host stuff
      self.nixosModules.HomeLabVMBoot
      self.nixosModules.HomeLabVMDisko
      self.nixosModules.HomeLabVMSops
    ];

    nixpkgs.hostPlatform = "x86_64-linux";

    console.keyMap = "hu";
    networking.hostName = "homelab-vm";

    networking.firewall.allowedTCPPorts = [80 443];

    users.users.user.linger = true;

    nixcfgs = {
      username = "user";
      kernel_module_lock = false;
    };

    home-manager.users."user" = import ../../../home/homelabvm.nix;
  };
}
