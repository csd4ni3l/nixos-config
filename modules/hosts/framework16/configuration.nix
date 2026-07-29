{self, inputs, ...}: {
  flake.nixosModules.framework16Configuration = {pkgs, lib, ...}: {
    system.stateVersion = "26.05";
    imports = [
      self.nixosModules.general
      self.nixosModules.desktop
      self.nixosModules.gaming
      self.nixosModules.virtualisation
      self.nixosModules.powersave
      self.nixosModules.hardening
      self.nixosModules.secureboot
      self.nixosModules.hostDisko
      self.nixosModules.hostImpermanence
      self.nixosModules.compatibility
    ];

    nixpkgs.config.allowUnfree = true; # NOTE: needed because of veracrypt
    nixpkgs.hostPlatform = "x86_64-linux";

    nixpkgs.overlays = [
      inputs.nix-cachyos-kernel.overlays.pinned
    ];

    boot = {
      kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-zen4;

      initrd.systemd.enable = true;

      initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
      ];
    };

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 5;
      memoryPercent = 50;
    };

    boot.plymouth.enable = true;

    networking = {
      hostName = "framework16";
      networkmanager = {
        enable = true;
        ethernet.macAddress = "random";

        wifi = {
          powersave = false;
          scanRandMacAddress = true;
          macAddress = "random";
        };
      };
    };

    console.keyMap = "hu";

    hardware.cpu.amd.updateMicrocode = true;

    # NOTE: Rules are host-specific, moved from hardening.nix
    services.usbguard.rules = ''
      allow id 1d6b:0002                                               # Linux USB 2.0 root hubs
      allow id 1d6b:0003                                               # Linux USB 3.x root hubs
      allow id 046d:c08b serial "205933F25943"                         # Logitech G502 HERO
      allow id 05e3:0610                                               # Internal Framework USB 2.0 hubs
      allow id 05e3:0625                                               # Internal Framework USB 3.x hub
      allow id 0e8d:e616 serial "000000000"                            # MediaTek Bluetooth
      allow id 32ac:0002 serial "11AD1D009612330C15270B00"             # Framework HDMI Expansion Card
      allow id 27c6:609c serial "UID250B1CD7_XXXX_MOC_B0"              # Goodix fingerprint reader
      allow id 32ac:0018 serial "FRAKDKEN0100000000"                   # Framework Laptop 16 keyboard module (ISO)
      allow id 18a5:0422 serial "WN6L17737000"                         # Portable SSD
      allow id 32ac:0005 serial "071C587D208A2D32"                     # Framework 250 GB Storage Expansion Card
      allow id 0bda:8156 serial "4013000001"                           # Framework 2.5 GbE Ethernet Expansion Card
      allow id 1050:0402                                               # Yubico Security Keys
      allow id 090c:2000 serial "CCYYMMDDHHmmSSRMT223"                 # ADATA 32GB pendrive 1
      allow id 090c:2000 serial "CCYYMMDDHHmmSSKAUUER"                 # ADATA 32GB pendrive 2
      allow id 090c:2000 serial "CCYYMMDDHHmmSS14RYN3"                 # ADATA 32GB pendrive 3
      allow id 0951:1666 serial "E0D55E625B4E18C198B30120"             # Kingston DataTraveler 3.0 128GB
      allow id 125f:dc1a serial "2122607280070066"                     # ADATA UV150 16GB pendrive
      allow id 0951:1666 serial "E0D55E6C711617503942000C"             # Kingston DataTraveler 3.0 64GB
      allow id 058f:6387 serial "CDCD1C5C"                             # Unknown Pendrive 2GB
    '';

    boot.kernelParams = [
      "abmlevel=0" # NOTE: Disable Adaptive Backlight Management which can make display colors look really bad
    ];

    # Pre-load all needed modules before modules are locked (from lsmod, the list is quite extensive, but nothing will break this way.)
    boot.kernelModules = [
      # filesystems
      "ext4"
      "vfat"
      "fat"
      "exfat"
      "fuse"
      "overlay"
      "autofs4"
      "mbcache"
      "jbd2"

      # storage
      "nvme"
      "nvme_core"
      "nvme_keyring"
      "nvme_auth"
      "sd_mod"
      "scsi_mod"
      "scsi_common"
      "usb_storage"
      "uas"

      # crypto / dm
      "dm_crypt"
      "dm_mod"
      "aes"
      "aesni_intel"
      "cbc"
      "xts"
      "ctr"
      "lrw"
      "gf128mul"
      "blowfish_generic"
      "blowfish_x86_64"
      "blowfish_common"
      "des_generic"
      "libdes"
      "cast5_avx_x86_64"
      "cast5_generic"
      "cast_common"
      "camellia_generic"
      "camellia_aesni_avx2"
      "camellia_aesni_avx_x86_64"
      "camellia_x86_64"
      "twofish_generic"
      "twofish_avx_x86_64"
      "twofish_x86_64_3way"
      "twofish_x86_64"
      "twofish_common"
      "serpent_avx2"
      "serpent_avx_x86_64"
      "serpent_sse2_x86_64"
      "serpent_generic"
      "algif_skcipher"
      "af_alg"
      "encrypted_keys"
      "trusted"
      "asn1_encoder"
      "tee"
      "aead"

      # zram / compression
      "zram"
      "842_decompress"
      "842_compress"
      "lz4hc_compress"
      "lz4_compress"

      # amdgpu / graphics
      "amdgpu"
      "amdxcp"
      "amdxdna"
      "drm_buddy"
      "drm_ttm_helper"
      "ttm"
      "drm_exec"
      "drm_suballoc_helper"
      "drm_display_helper"
      "gpu_sched"
      "drm_panel_backlight_quirks"
      "i2c_algo_bit"
      "video"
      "cec"

      # audio
      "snd"
      "snd_hda_intel"
      "snd_hda_codec"
      "snd_hda_core"
      "snd_hda_codec_generic"
      "snd_hda_codec_hdmi"
      "snd_hda_codec_atihdmi"
      "snd_hda_codec_alc269"
      "snd_hda_codec_realtek_lib"
      "snd_hda_scodec_component"
      "snd_hwdep"
      "snd_pcm"
      "snd_pcm_dmaengine"
      "snd_timer"
      "snd_compress"
      "snd_soc_core"
      "snd_soc_sdca"
      "snd_sof"
      "snd_sof_utils"
      "snd_sof_pci"
      "snd_sof_xtensa_dsp"
      "snd_sof_amd_acp"
      "snd_sof_amd_acp70"
      "snd_sof_amd_acp63"
      "snd_sof_amd_vangogh"
      "snd_sof_amd_rembrandt"
      "snd_sof_amd_renoir"
      "snd_soc_acpi"
      "snd_soc_acpi_amd_match"
      "snd_soc_acpi_amd_sdca_quirks"
      "snd_amd_acpi_mach"
      "snd_amd_sdw_acpi"
      "snd_acp_config"
      "snd_acp_pci"
      "snd_acp_legacy_common"
      "snd_pci_acp6x"
      "snd_pci_acp5x"
      "snd_pci_acp3x"
      "snd_rn_pci_acp3x"
      "snd_intel_dspcfg"
      "snd_intel_sdw_acpi"
      "snd_pci_ps"
      "ac97_bus"
      "soundwire_amd"
      "soundwire_bus"
      "soundwire_generic_allocation"
      "snd_seq"
      "snd_seq_device"
      "snd_seq_dummy"
      "snd_hrtimer"
      "snd_acp_pci"
      "amd_atl"
      "amd_sfh"

      # bluetooth
      "bluetooth"
      "btusb"
      "btintel"
      "btbcm"
      "btrtl"
      "btmtk"
      "bnep"
      "rfcomm"

      # wifi / networking
      "mt7921e"
      "mt7921_common"
      "mt792x_lib"
      "mt76_connac_lib"
      "mt76"
      "mac80211"
      "cfg80211"
      "libarc4"
      "r8152"
      "mii"
      "usbnet"
      "cdc_ether"
      "cdc_ncm"
      "cdc_mbim"
      "cdc_wdm"
      "wireguard"
      "libcurve25519"
      "ip6_udp_tunnel"
      "udp_tunnel"
      "dummy"
      "tun"

      # nftables / firewall
      "nf_tables"
      "nfnetlink"
      "nft_compat"
      "nft_ct"
      "nft_fib"
      "nft_fib_ipv4"
      "nft_fib_ipv6"
      "nf_conntrack"
      "nf_defrag_ipv4"
      "nf_defrag_ipv6"
      "xt_conntrack"
      "xt_tcpudp"
      "xt_pkttype"
      "x_tables"
      "ipt_rpfilter"
      "ip6t_rpfilter"
      "sch_fq_codel"

      # kvm / virtualization
      "kvm"
      "kvm_amd"
      "irqbypass"
      "ccp"
      "amdtee"

      # platform / hardware monitoring
      "k10temp"
      "sp5100_tco"
      "watchdog"
      "i2c_piix4"
      "i2c_smbus"
      "amd_pmc"
      "amd_pmf"
      "edac_mce_amd"
      "edac_core"
      "intel_rapl_msr"
      "intel_rapl_common"
      "rapl"
      "thunderbolt"
      "typec"
      "typec_ucsi"
      "ucsi_acpi"
      "roles"

      # input / HID
      "atkbd"
      "libps2"
      "serio"
      "evdev"
      "button"
      "mousedev"
      "hid_multitouch"
      "hid_sensor_als"
      "hid_sensor_trigger"
      "hid_sensor_iio_common"
      "hid_sensor_hub"
      "kfifo_buf"
      "industrialio"
      "hid_generic"
      "usbhid"
      "i2c_hid"
      "i2c_hid_acpi"
      "input_leds"
      "led_class"
      "led_class_multicolor"
      "rtc_cmos"
      "spd5118"
      "vivaldi_fmap"

      # ChromeOS EC (Framework laptop)
      "cros_ec"
      "cros_ec_proto"
      "cros_ec_dev"
      "cros_ec_lpcs"
      "cros_ec_sysfs"
      "cros_ec_debugfs"
      "cros_ec_hwmon"
      "cros_charge_control"
      "cros_ec_chardev"
      "gpio_cros_ec"
      "leds_cros_ec"

      # misc
      "af_packet"
      "rfkill"
      "soundcore"
      "uinput"
      "loop"
      "tcp_diag"
      "udp_diag"
      "inet_diag"
      "msr"
      "nls_ascii"
      "nls_cp437"
      "dmi_sysfs"
      "wmi"
      "wmi_bmof"
      "tiny_power_button"
      "onboard_usb_dev"
      "xhci_pci"
      "xhci_hcd"
      "ac"
      "battery"
      "thermal"
      "mac_hid"
      "sch_fq_codel"
    ];

    environment.systemPackages = with pkgs; [
      framework-control
      framework-tool
    ];

    systemd.services.framework-control = {
      description = "Framework Control Service";

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [
        framework-tool
        coreutils
        bash
      ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.framework-control}/bin/framework-control";
        Restart = "on-failure";
        RestartSec = 5;

        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        LockPersonality = true;
        RestrictRealtime = true;
        NoNewPrivileges = true;
        UMask = "0077";
        SystemCallArchitectures = "native";
      };
    };
  };
}
