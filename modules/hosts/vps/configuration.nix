{self, ...}: {
  flake.nixosModules.VPSConfiguration = {
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

      # hardening
      self.nixosModules.HardeningKernel
      self.nixosModules.HardeningEnvironmentLockdown
      self.nixosModules.HardeningMisc
      self.nixosModules.HardeningNoSUID
      self.nixosModules.HardeningPolkitNoSUID
      self.nixosModules.HardeningServices
      self.nixosModules.HardeningSysCtl

      # host stuff
      self.nixosModules.VPSBoot
      self.nixosModules.VPSDisko
      self.nixosModules.VPSSops
    ];

    nixpkgs.hostPlatform = "x86_64-linux";

    console.keyMap = "hu";
    networking.hostName = "vps";

    users.users.deploy = {
      isNormalUser = true;
      description = "unprivileged container runtime user";
      uid = 1001;
      extraGroups = [];
      shell = pkgs.zsh;
      linger = true;
    };
    systemd.targets.network-online.wantedBy = ["multi-user.target"];

    # rootless podman + pangolin prerequisites
    boot.kernelModules = ["wireguard"];
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.ip_unprivileged_port_start" = 80;
    };
    networking.firewall = {
      allowedTCPPorts = [80 443 3306 42712];
      allowedUDPPorts = [51820 42712 63536];
    };

    services.qemuGuest.enable = true;

    nixcfgs = {
      username = "user";
      kernel_module_lock = true;
    };

    home-manager.users."user" = import ../../../home/vps.nix;
    home-manager.users."deploy" = import ../../../home/deploy-vps.nix;
  };
}
