{self, ...}: {
  flake.nixosModules.HomeLabVMConfiguration = {
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

    services.resolved = {
      enable = true;
      settings.Resolve.FallbackDNS = ["1.1.1.1" "1.0.0.1"];
    };
    networking.networkmanager.dns = "systemd-resolved";

    networking.firewall.allowedTCPPorts = [80 443];

    users.users.deploy = {
      isNormalUser = true;
      description = "unprivileged container runtime user";
      uid = 1001;
      extraGroups = [];
      shell = pkgs.bash;
      linger = true;
    };

    systemd.targets.network-online.wantedBy = ["multi-user.target"];

    services.qemuGuest.enable = true;

    # NOTE: security degradation but NPM needs to use 80 and 443
    boot.kernel.sysctl = {
      "net.ipv4.ip_unprivileged_port_start" = 80;
      "net.ipv6.ip_unprivileged_port_start" = 80;
    };

    nixcfgs = {
      username = "user";
      kernel_module_lock = false;
    };

    home-manager.users."user" = import ../../../home/homelabvm.nix;
    home-manager.users."deploy" = import ../../../home/deploy-homelabvm.nix;
  };
}
