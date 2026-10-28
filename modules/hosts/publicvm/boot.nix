{self, ...}: {
  flake.nixosModules.PublicVMBoot = {pkgs, ...}: {
    boot = {
      kernelPackages = pkgs.linuxPackages_latest; # NOTE: can't use hardened kernel as it disables user namespaces

      initrd.availableKernelModules = [
        "virtio_blk"
        "virtio_pci"
        "virtio_scsi"
        "virtio_net"
        "virtio_console"
      ];

      kernelModules = [
        # Network / firewall (iptables / nftables)
        "x_tables"
        "xt_nat"
        "xt_addrtype"
        "xt_mark"
        "xt_comment"
        "xt_conntrack"
        "xt_tcpudp"
        "xt_pkttype"
        "xt_MASQUERADE"
        "nft_compat"
        "nf_tables"
        "nf_nat"
        "nf_conntrack"
        "nf_defrag_ipv4"
        "nf_defrag_ipv6"
        "nfnetlink"
        "nft_chain_nat"
        "ip6t_rpfilter"
        "ipt_rpfilter"
        "sch_fq_codel"

        # Virtualization / networking drivers
        "tun"
        "overlay"
        "af_packet"
        "bridge"
        "veth"
        "net_failover"
        "failover"

        # KVM / virtualization
        "virtio_balloon"
        "virtio_net"
        "virtio_console"
        "virtio_scsi"
        "virtio_pci"
        "vmgenid"

        # Storage / filesystems
        "ext4"
        "jbd2"
        "mbcache"
        "crc16"
        "vfat"
        "fat"
        "nls_ascii"
        "nls_cp437"
        "loop"
        "fuse"
        "zram"
        "842_compress"
        "842_decompress"
        "lz4_compress"
        "lz4hc_compress"
        "dm_mod"
        "sd_mod"
        "scsi_mod"
        "scsi_common"
        "dmi_sysfs"
        "qemu_fw_cfg"
        "efivarfs"
        "autofs4"

        # Crypto
        "aesni_intel"
        "aead"
        "gf128mul"
        "ctr"

        # Input / HID
        "atkbd"
        "libps2"
        "serio"
        "serio_raw"
        "i8042"
        "evdev"
        "input_leds"
        "led_class"

        # Misc / display / power
        "bochs"
        "button"
        "tiny_power_button"
        "rtc_cmos"
      ];
    };
  };
}
