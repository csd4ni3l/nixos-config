{self, ...}: {
  flake.nixosModules.HomeLabVMBoot = {
    pkgs,
    inputs,
    ...
  }: {
    nixpkgs.overlays = [
      inputs.nix-cachyos-kernel.overlays.pinned
    ];

    boot = {
      kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-hardened;

      initrd.systemd.enable = true;

      initrd.availableKernelModules = [
        "virtio_blk"
        "virtio_pci"
        "virtio_scsi"
        "virtio_net"
        "virtio_console"
      ];
    };
  };
}
