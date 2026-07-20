{self, pkgs, ...}: {
  flake.nixosModules.hardening = {
    pkgs, lib, ...
  }: {
      security.protectKernelImage = true;
      security.lockKernelModules = true;

      environment.systemPackages = [ pkgs.kernel-hardening-checker ];

      networking.modemmanager.enable = false;

      services = {
          # mDNS/DNS-SD
          avahi.enable = false;

          # Geoclue (location services)
          geoclue2.enable = false;

          # NOTE: I need udisks2 for mounting MTP & SMB
          # udisks2.enable = false;

          # NOTE: can safely disable, as if needed, will be started automatically
          accounts-daemon.enable = false;
      };

      systemd.services = {
          # Harden Bluetooth Service
          bluetooth.serviceConfig = {
            ProtectKernelTunables = lib.mkDefault true;
            ProtectKernelModules = lib.mkDefault true;
            ProtectKernelLogs = lib.mkDefault true;
            ProtectHostname = true;
            ProtectControlGroups = true;
            ProtectProc = "invisible";
            SystemCallFilter = [
              "~@obsolete"
              "~@cpu-emulation"
              "~@swap"
              "~@reboot"
              "~@mount"
            ];
            SystemCallArchitectures = "native";
        };
      };

      # TODO: figure out something cause this breaks browsers and stuff
      # environment.memoryAllocator.provider = "graphene-hardened-light";

      security.sudo.extraConfig = ''
        Defaults use_pty
        Defaults timestamp_timeout=5
        Defaults lecture = never
      '';

      # Use & Force NTS (Network Time Security)
      services.timesyncd.enable = false;
      services.chrony = {
        enable = true;

        extraConfig = ''
          server time.cloudflare.com iburst nts
          server ntppool1.time.nl iburst nts
          server nts.netnod.se iburst nts
          server ptbtime1.ptb.de iburst nts
          server time.dfm.dk iburst nts

          minsources 3
          authselectmode require

          makestep 1.0 3

          cmdport 0
        '';
      };

      networking.firewall.enable = true;

      # NOTE: fixes ProtonVPN not connecting
      boot.kernelModules = [
        "wireguard"
        "dummy"

        "nf_tables"
        "nf_conntrack"
        "nfnetlink"

        "nft_ct"
        "nft_fib_ipv4"
        "nft_fib_ipv6"
      ];

      boot.kernelParams = [
        "quiet"
        "abmlevel=0" # Disable Adaptive Backlight Management which can make display colors look really bad

        # kernel parameters from secureblue
        "hash_pointers=always" # Hash kernel pointers even if slab_debug is enabled.
        "init_on_alloc=1" # Fill newly allocated pages and heap objects with zeroes, mitigating use-after-free vulnerabilities.
        "init_on_free=1" # Fill freed pages and heap objects with zeroes, mitigating use-after-free vulnerabilities.
        "iommu=force" "intel_iommu=on" "amd_iommu=force_isolation" # Mitigate DMA attacks by enabling IOMMU.
        "iommu.passthrough=0" # Disable IOMMU bypass.
        "iommu.strict=1" # Synchronously invalidate IOMMU hardware TLBs.
        "kvm_amd.sev=1" "kvm_amd.sev_es=1" "kvm_amd.sev_snp=1" # Enable AMD Secure Encrypted Virtualization (SEV) and extensions.
        "kvm-intel.vmentry_l1d_flush=always" # Enable unconditional flushes, required for complete L1D vulnerability mitigation.
        "kvm.mitigate_smt_rsb=1" # Mitigate cross-thread return address predictions vulnerability for certain KVM hypervisor configurations.
        "l1d_flush=on" # Enable the mechanism to flush the L1D cache on context switch.
        "l1tf=full,force" # Force enable all available mitigations for the L1TF vulnerability.
        "lockdown=confidentiality" # Enable kernel lockdown in the strictest mode.
        "loglevel=0" # Only log level 0 (system is unusable) messages to the console.
        "mitigations=auto" # Automatically mitigate all known CPU vulnerabilities (SMT disable removed compared to SecureBlue default config)
        "module.sig_enforce=1" # Only allow kernel modules that have been signed with a valid key to be loaded.
        "page_alloc.shuffle=1" # Enable page allocator freelist randomization, reducing page allocation predictability.
        "proc_mem.force_override=ptrace" # Only allow memory permissions for /proc/<pid>/mem to be overridden by active ptracers.
        "pti=on" # Enable kernel page table isolation.
        "random.trust_bootloader=off" # Disable trusting the use of the seed passed by the bootloader.
        "random.trust_cpu=off" # Disable CPU-based entropy sources, as it’s not auditable and has resulted in vulnerabilities.
        "randomize_kstack_offset=on" # Randomize kernel stack offset on each syscall, making certain types of attacks more difficult.
        "rd.shell=0" "rd.emergency=halt" # Mitigate initramfs malware injection attack.
        "slab_debug=FZ" # Enable sanity checks and red zoning for the kernel slab allocator.
        "slab_nomerge" # Disable the merging of slabs, increasing difficulty of heap exploitation.
        "spec_store_bypass_disable=on" # Disable spec store bypass for all programs.
        "spectre_v2=on" # Turn on spectre_v2 mitigations at boot time for all programs.
        "ssbd=force-on" # Enable mitigation for Speculative Store Bypass vulnerability for both kernel and userspace on vulnerable CPUs.
        "systemd.ssh_auto=no" # Disable automatic creation of socket-activated SSH server by systemd (see systemd-ssh-generator(8) for details), which can lead to security vulnerabilities.
        "vdso32=0" # Disable 32-bit vDSO.
        "vsyscall=none" # Disable vsyscall as it is both obsolete and enables an ROP attack vector.
        "extra_latent_entropy" # feeds more entropy into the boot-time pool.
        "tsx=off" # disables Intel TSX (Transactional Synchronization Extensions), which has been a repeated source of speculative-execution side channels
      ];

      # SecureBlue module blacklist
      boot.blacklistedKernelModules = [
        # unused network protocols
        "dccp"
        "xt_dccp"
        "sctp"
        "xt_sctp"
        "sctp_diag"
        "rds"
        "rds_rdma"
        "rds_tcp"
        "tipc"
        "tipc_diag"
        "n-hdlc"
        "hdlcdrv"
        "ax25"
        "netrom"
        "x25"
        "rose"
        "decnet"
        "econet"
        "af_802154"
        "ipx"
        "appletalk"
        "psnap"
        "p8023"
        "p8022"
        "atm"
        "usbatm"
        "xusbatm"
        "pppoatm"
        "atmtcp"
        "mctp-serial"
        "mctp-usb"
        "mctp-i3c"
        "batman-adv"

        # firewire and thunderbolt
        "firewire-core"
        "firewire_core"
        "firewire-ohci"
        "firewire_ohci"
        "firewire_sbp2"
        "firewire-sbp2"
        "firewire-net"

        # I might need thunderbolt
        # "thunderbolt"
        # "thunderbolt_net"

        "ohci1394"
        "sbp2"
        "dv1394"
        "raw1394"
        "video1394"
        # https://github.com/torvalds/linux/blob/master/drivers/firewire/nosy.c
        "nosy"
        # https://github.com/torvalds/linux/blob/master/drivers/media/firewire/firedtv-dvb.c
        "firedtv"

        # unused filesystems
        "cramfs"
        "freevxfs"
        "jffs2"
        "hfs"
        "hfsplus"
        "squashfs"
        "udf"
        "cifs"
        "cifs_md4"
        "nfs"
        "nfsv3"
        "nfsv4"
        "rpcsec_gss_krb5"
        "auth_rpcgss"
        "nfs_acl"
        "nfsd"
        "nfs_layout_flexfiles"
        "nfs_layout_nfsv41_files"
        "nfs_localio"
        # https://github.com/torvalds/linux/blob/master/fs/nfs_common/grace.c
        "grace"
        # https://github.com/torvalds/linux/blob/master/fs/lockd/svc.c
        "lockd"
        "ksmbd"
        "gfs2"
        "reiserfs"
        "kafs"
        "orangefs"
        "9p"
        "9pnet"
        "9pnet_fd"
        "9pnet_rdma"
        "9pnet_usbg"
        "9pnet_virtio"
        "9pnet_xen"
        "adfs"
        "affs"
        "afs"
        "befs"
        "ceph"
        "coda"
        "ecryptfs"
        "jfs"
        "minix"
        "nilfs2"
        "ocfs2"
        "romfs"
        "ubifs"
        "zonefs"
        "sysv"
        "ufs"
        # https://documentation.suse.com/sle-ha/12-SP5/html/SLE-HA-all/cha-ha-storage-dlm.html
        "dlm"
        # https://en.wikipedia.org/wiki/OCFS2
        "ocfs2_dlm"
        "ocfs2_dlmfs"
        "ocfs2_nodemanager"
        "ocfs2_stackglue"
        "ocfs2_stack_o2cb"
        "ocfs2_stack_user"


        # disable GNSS
        "gnss"
        "gnss-mtk"
        "gnss-serial"
        "gnss-sirf"
        "gnss-usb"
        "gnss-ubx"

        # https://en.wikipedia.org/wiki/Bluetooth#History_of_security_concerns
        # "bluetooth"
        # "btusb"

        # block loading ath_pci
        "ath_pci"

        # X86 android tablet support
        # https://github.com/torvalds/linux/tree/master/drivers/platform/x86/x86-android-tablets
        "x86-android-tablets"

        # block loading cdrom
        "cdrom"
        "sr_mod"

        # dirtyfrag mitigation: https://github.com/V4bel/dirtyfrag#mitigation
        # RxRPC network protocol: https://www.kernel.org/doc/html/latest/networking/rxrpc.html
        "rxrpc"

        # esp4 and esp6 provide support for Encapsulating Security Payload, part of IPSec.
        "esp4"
        "esp4_offload"
        "esp6"
        "esp6_offload"

        # xfrm, another part of IPSec involved in related exploits
        "nft_xfrm"
        "xfrm4_tunnel"
        "xfrm6_tunnel"
        "xfrm_algo"
        "xfrm_interface"
        "xfrm_ipcomp"
        "xfrm_iptfs"
        "xfrm_user"

        # disable remaining ipsec modules
        "ah4"
        "ah6"
        "ipcomp"
        "ipcomp6"
        "af_key"

        # disable l2tp (depends on ipsec)
        "l2tp_core"
        "l2tp_debugfs"
        "l2tp_eth"
        "l2tp_ip"
        "l2tp_ip6"
        "l2tp_netlink"
        "l2tp_ppp"
        "xt_l2tp"

        # disable Sun RPC: https://en.wikipedia.org/wiki/Sun_RPC
        "sunrpc"

        # legacy interfaces
        # https://en.wikipedia.org/wiki/Parallel_port
        "parport"
        "parport_cs"
        "parport_pc"
        "parport_serial"
        "pps_parport"
        "i2c-parport"
        # https://github.com/torvalds/linux/blob/master/drivers/char/ppdev.c
        "ppdev"
        # https://github.com/torvalds/linux/blob/master/drivers/char/lp.c
        "lp"

        # https://en.wikipedia.org/wiki/Game_port
        "gameport"
        # https://en.wikipedia.org/wiki/Floppy_disk
        "floppy"

        # kernel debugging / development modules
        # https://linux.die.net/man/8/mce-inject
        "mce-inject"
        # https://github.com/torvalds/linux/blob/master/mm/hwpoison-inject.c
        "hwpoison-inject"
        # https://github.com/torvalds/linux/blob/master/drivers/pci/pcie/aer_inject.c
        "aer_inject"
        # https://github.com/torvalds/linux/blob/master/drivers/scsi/scsi_debug.c
        "scsi_debug"
        # https://github.com/torvalds/linux/blob/master/drivers/usb/serial/usb_debug.c
        "usb_debug"
        # https://github.com/torvalds/linux/blob/master/kernel/trace/ring_buffer_benchmark.c
        "ring_buffer_benchmark"
        # https://github.com/torvalds/linux/blob/master/drivers/gpu/drm/vkms/vkms_drv.c
        "vkms"
        # diagnostic module for vsock: https://man7.org/linux/man-pages/man7/vsock.7.html
        "vsock_diag"
        # diagnostic module for xdp: https://github.com/torvalds/linux/blob/master/net/xdp/xsk_diag.c
        "xsk_diag"
        # https://docs.kernel.org/admin-guide/media/visl.html
        # https://github.com/torvalds/linux/tree/master/drivers/media/test-drivers/visl
        "visl"
        # https://github.com/torvalds/linux/blob/master/drivers/media/test-drivers/vim2m.c
        "vim2m"
        # https://docs.kernel.org/admin-guide/media/vimc.html
        # https://github.com/torvalds/linux/tree/master/drivers/media/test-drivers/vimc
        "vimc"
        # disable vivid
        "vivid"
        # https://github.com/torvalds/linux/blob/master/drivers/usb/gadget/udc/dummy_hcd.c
        "dummy_hcd"
        # https://manpages.ubuntu.com/manpages/bionic/man4/nandsim.4freebsd.html
        # https://github.com/torvalds/linux/blob/master/drivers/mtd/nand/raw/nandsim.c
        "nandsim"
        # https://github.com/torvalds/linux/blob/master/drivers/mtd/devices/mtdram.c
        "mtdram"

        # kernel message logging over UDP
        # https://www.kernel.org/doc/Documentation/networking/netconsole.txt
        "netconsole"

        # automotive/industrial linux
        # https://www.ti.com/lit/ds/symlink/dp83tg720s-q1.pdf
        "dp83tg720"
        # https://github.com/torvalds/linux/blob/master/drivers/net/phy/marvell-88q2xxx.c
        "marvell-88q2xxx"
        # https://github.com/torvalds/linux/blob/master/drivers/net/phy/marvell-88x2222.c
        "marvell-88x2222"
        # https://www.microchip.com/en-us/products/high-speed-networking-and-video/ethernet/single-pair-ethernet
        "microchip_t1s"
        # car backup cameras
        # https://github.com/torvalds/linux/blob/master/drivers/media/i2c/max9271.c
        "max9271"
        # https://en.wikipedia.org/wiki/CAN_bus
        # https://en.wikipedia.org/wiki/Vehicle_bus
        "can"
        "can327"
        "can-bcm"
        "can-gw"
        "can-isotp"
        "can-j1939"
        "can-raw"
        "ctucanfd"
        "ctucanfd_pci"
        "ifi_canfd"
        "m_can"
        "m_can_pci"
        "slcan"
        "vcan"
        "vxcan"
        # https://github.com/torvalds/linux/blob/master/drivers/net/can/usb/peak_usb/pcan_usb_core.c
        "peak_usb"
        # https://github.com/torvalds/linux/blob/master/drivers/net/can/peak_canfd/peak_pciefd_main.c
        "peak_pciefd"
        # https://github.com/torvalds/linux/tree/master/drivers/net/can/usb/kvaser_usb
        "kvaser_usb"
        # https://github.com/torvalds/linux/blob/master/drivers/net/can/usb/gs_usb.c
        "gs_usb"
        # https://en.wikipedia.org/wiki/6LoWPAN
        "6lowpan"
        "bluetooth_6lowpan"
        "ieee802154_6lowpan"


        # RDMA https://wiki.debian.org/RDMA
        # https://github.com/torvalds/linux/blob/master/net/smc/smc.h
        "smc"
        "smc_diag"
        "erdma"
        "ionic_rdma"
        "irdma"
        "nvme-rdma"
        "nvmet-rdma"
        "ocrdma"
        "rdma_cm"
        "rdma_rxe"
        "rdma_ucm"
        "rdmavt"
        "rpcrdma"
        "vmw_pvrdma"


        # GPIB
        # https://en.wikipedia.org/wiki/GPIB
        # https://github.com/torvalds/linux/blob/master/drivers/gpib/common/gpib_os.c
        "gpib_common"
        # https://github.com/torvalds/linux/blob/master/drivers/gpib/agilent_82350b/agilent_82350b.c
        "agilent_82350b"
        # https://github.com/torvalds/linux/blob/master/drivers/gpib/agilent_82357a/agilent_82357a.c
        "agilent_82357a"
        # https://github.com/torvalds/linux/blob/master/drivers/gpib/cb7210/cb7210.c
        "cb7210"
        # https://github.com/torvalds/linux/blob/master/drivers/gpib/cec/cec_gpib.c
        "cec_gpib"
        # https://github.com/torvalds/linux/blob/master/drivers/gpib/ines/ines_gpib.c
        "ines_gpib"
        # https://github.com/torvalds/linux/blob/master/drivers/gpib/lpvo_usb_gpib/lpvo_usb_gpib.c
        "lpvo_usb_gpib"
        # https://github.com/torvalds/linux/blob/master/drivers/gpib/nec7210/nec7210.c
        "nec7210"
        # https://github.com/torvalds/linux/blob/master/drivers/gpib/ni_usb/ni_usb_gpib.c
        "ni_usb_gpib"
        # # https://github.com/torvalds/linux/blob/master/drivers/gpib/tms9914/tms9914.c
        "tms9914"
        # https://github.com/torvalds/linux/tree/master/drivers/gpib/tnt4882
        "tnt4882"


        # DVB and TV receivers
        # https://www.kernel.org/doc/html/v4.9/media/uapi/dvb/intro.html
        # https://wiki.archlinux.org/title/DVB-T
        "dvb-as102"
        "dvb-bt8xx"
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/bt8xx/dst_ca.c
        "dst_ca"
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/bt8xx/dst.c
        "dst"
        "dvb-core"
        "dvb-pll"
        "dvb-ttusb-budget"
        "dvb-usb"
        "dvb-usb-a800"
        "dvb-usb-af9005"
        "dvb-usb-af9005-remote"
        "dvb-usb-af9015"
        "dvb-usb-af9035"
        "dvb-usb-anysee"
        "dvb-usb-au6610"
        "dvb-usb-az6007"
        "dvb-usb-az6027"
        "dvb-usb-ce6230"
        "dvb-usb-cinergyT2"
        "dvb-usb-cxusb"
        "dvb-usb-dib0700"
        "dvb-usb-dibusb-common"
        "dvb-usb-dibusb-mb"
        "dvb-usb-dibusb-mc"
        "dvb-usb-dibusb-mc-common"
        "dvb-usb-digitv"
        "dvb-usb-dtt200u"
        "dvb-usb-dtv5100"
        "dvb-usb-dvbsky"
        "dvb-usb-dw2102"
        "dvb-usb-ec168"
        "dvb-usb-gl861"
        "dvb-usb-gp8psk"
        "dvb-usb-lmedm04"
        "dvb-usb-m920x"
        "dvb-usb-mxl111sf"
        "dvb-usb-nova-t-usb2"
        "dvb-usb-opera"
        "dvb-usb-pctv452e"
        "dvb-usb-rtl28xxu"
        "dvb-usb-technisat-usb2"
        "dvb-usb-ttusb2"
        "dvb-usb-umt-010"
        "dvb_usb_v2"
        "dvb-usb-vp702x"
        "dvb-usb-vp7045"
        # https://www.kernel.org/doc/Documentation/media/dvb-drivers/ttusb-dec.rst
        "ttusb_dec"
        "ttusbdecfe"
        # https://github.com/torvalds/linux/tree/master/drivers/media/mmc/siano
        # https://docs.kernel.org/admin-guide/media/siano-cardlist.html
        "smsusb"
        "smsdvb"
        "smsmdtv"
        "smssdio"
        # https://github.com/torvalds/linux/tree/master/drivers/media/common/b2c2
        "b2c2-flexcop"
        "b2c2-flexcop-pci"
        "b2c2-flexcop-usb"
        # https://github.com/torvalds/linux/tree/master/drivers/media/usb/au0828
        "au0828"
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/saa7146/mxb.c
        "mxb"
        # https://www.linuxtv.org/wiki/index.php/NXP_SAA716x#Saa7164_IC_chip_information
        "saa7164"
        # https://www.linuxtv.org/wiki/index.php/Radio_Data_System_(RDS)
        "saa6588"
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/smipcie/smipcie-main.c
        "smipcie"
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/pluto2/pluto2.c
        "pluto2"
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/ngene/ngene-dvb.c
        "ngene"
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/mantis/mantis_dvb.c
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/mantis/hopper_cards.c
        "mantis"
        "mantis_core"
        "hopper"
        # https://github.com/torvalds/linux/blob/master/include/uapi/linux/ivtv.h
        # https://www.kernel.org/doc/html/v4.8/media/v4l-drivers/ivtv.html
        "ivtv"
        "ivtvfb"
        # https://github.com/torvalds/linux/tree/master/drivers/media/dvb-frontends
        "a8293"
        "af9013"
        "af9033"
        "as102_fe"
        "ascot2e"
        "atbm8830"
        "au8522_common"
        "au8522_decoder"
        "au8522_dig"
        "bcm3510"
        "cx22700"
        "cx22702"
        "cx24110"
        "cx24113"
        "cx24116"
        "cx24117"
        "cx24120"
        "cx24123" # used by functions like read/write or aio_read/aio_write for operations on data accessed by f
        "cxd2099"
        "cxd2820r"
        "cxd2841er"
        "cxd2880-spi"
        "dib0070"
        "dib0090"
        "dib3000mb"
        "dib3000mc"
        "dib7000m"
        "dib7000p"
        "dib8000"
        "dibx000_common"
        "drx39xyj"
        "drxd"
        "drxk"
        "ds3000"
        "ec100"
        "gp8psk-fe"
        "helene"
        "horus3a"
        "isl6405"
        "isl6421"
        "isl6423"
        "itd1000"
        "ix2505v"
        "l64781"
        "lg2160"
        "lgdt3305"
        "lgdt3306a"
        "lgdt330x"
        "lgs8gxx"
        "lnbh25"
        "lnbp21"
        "lnbp22"
        "m88ds3103"
        "m88rs2000"
        "mb86a16"
        "mb86a20s"
        "mn88472"
        "mn88473"
        "mt312"
        "mt352"
        "mxl5xx"
        "mxl692"
        "nxt200x"
        "nxt6000"
        "or51132"
        "or51211"
        "rtl2830"
        "rtl2832"
        "s5h1409"
        "s5h1411"
        "s5h1420"
        "s921"
        "si2165"
        "si2168"
        "si21xx"
        "sp2"
        "sp887x"
        "stb0899"
        "stb6000"
        "stb6100"
        "stv0288"
        "stv0297"
        "stv0299"
        "stv0367"
        "stv0900"
        "stv090x"
        "stv0910"
        "stv6110"
        "stv6110x"
        "stv6111"
        "tc90522"
        "tda10021"
        "tda10023"
        "tda10048"
        "tda1004x"
        "tda10071"
        "tda10086"
        "tda18271c2dd"
        "tda665x"
        "tda8083"
        "tda8261"
        "tda826x"
        "ts2020"
        "tua6100"
        "ves1820"
        "ves1x93"
        "zd1301_demod"
        "zl10036"
        "zl10039"
        "zl10353"
        # https://github.com/torvalds/linux/tree/master/drivers/media/tuners
        "e4000"
        "fc0011"
        "fc0012"
        "fc0013"
        "fc2580"
        "it913x"
        "m88rs6000t"
        "max2165"
        "mc44s803"
        "mt2060"
        "mt2063"
        "mt20xx"
        "mt2131"
        "mt2266"
        "mxl301rf"
        "mxl5005s"
        "mxl5007t"
        "qm1d1b0004"
        "qm1d1c0042"
        "qt1010"
        "r820t"
        "si2157"
        "tda18212"
        "tda18218"
        "tda18250"
        "tda18271"
        "tda827x"
        "tda8290"
        "tda9887"
        "tea5761"
        "tea5767"
        "tua9001"
        "tuner"
        "tuner-simple"
        "tuner-types"
        "xc2028"
        "xc4000"
        "xc5000"
        "zl10036"
        "zl10039"
        "zl10353"
        # https://github.com/torvalds/linux/tree/master/drivers/media/usb/dvb-usb-v2
        "mxl111sf-demod"
        "mxl111sf-tuner"
        "zd1301"
        "zd1301_demod"
        # https://docs.kernel.org/admin-guide/media/saa7134.html
        "saa7134"
        "saa7134-alsa"
        "saa7134-dvb"
        "saa7134-empress"
        "saa7134-go7007"
        # https://github.com/torvalds/linux/blob/master/drivers/media/usb/cx231xx/cx231xx.h
        "cx231xx"
        "cx231xx-alsa"
        "cx231xx-dvb"
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/cx88/cx88.h
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/cx88/cx88-input.c
        "cx88-alsa"
        "cx88-blackbird"
        "cx88-dvb"
        "cx88-vp3054-i2c"
        "cx88xx"
        "cx8800"
        "cx8802"
        # https://www.kernel.org/doc/html/v4.9/media/v4l-drivers/em28xx-cardlist.html
        "em28xx"
        "em28xx-alsa"
        "em28xx-dvb"
        "em28xx-rc"
        "em28xx-v4l"
        # https://www.kernelconfig.io/CONFIG_DVB_NETUP_UNIDVB
        "netup-unidvb"
        # https://linuxtv.org/wiki/index.php/Bttv#Associated_bttv_driver_modules
        "bttv"
        "bt819"
        "bt856"
        "bt866"
        "bt878"
        # https://wiki.mythtv.org/wiki/Snd-bt87x
        "snd-bt87x"
        # https://github.com/torvalds/linux/blob/master/drivers/media/usb/hdpvr/hdpvr.h
        # https://www.hauppauge.com/pages/products/data_hdpvr.html
        "hdpvr"
        # https://www.kernel.org/doc/html/v4.10/media/v4l-drivers/pvrusb2.html
        "pvrusb2"
        # https://www.linuxtv.org/wiki/index.php/Philips_SAA7146
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/saa7146/hexium_orion.c
        "saa7146"
        "saa7146_vv"
        "hexium_gemini"
        "hexium_orion"
        # http://www.szmjd.com/Attachments/product/201501/54c5e68c78140.pdf
        "go7007"
        "go7007-loader"
        "go7007-usb"
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/pt1/pt1.c
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/pt3/pt3.c
        "earth-pt1"
        "earth-pt3"
        # https://satline.tv/knowledge-base/digital-devices-octopus-twin-ci/
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/ddbridge/ddbridge-ci.c
        "ddbridge"
        "ddbridge-dummy-fe"
        # https://linuxtv.org/wiki/index.php/Conexant_CX23885/7/8
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/cx23885/cx23885.h
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/cx23885/altera-ci.c
        "cx23885"
        "altera-ci"
        # https://linuxtv.org/wiki/index.php/Cx18_devices_(cx23418)e
        "cx18"
        "cx18-alsa"
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/ttpci/budget-core.c
        "budget"
        "budget-av"
        "budget-ci"
        "budget-core"


        # joystick drivers
        # https://github.com/torvalds/linux/tree/master/drivers/input/joystick
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/a3d.c
        "a3d"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/adc-joystick.c
        "adc-joystick"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/adi.c
        "adi"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/analog.c
        "analog"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/cobra.c
        "cobra"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/db9.c
        "db9"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/gamecon.c
        "gamecon"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/gf2k.c
        "gf2k"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/grip.c
        "grip"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/grip_mp.c
        "grip_mp"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/guillemot.c
        "guillemot"
        # https://github.com/torvalds/linux/tree/master/drivers/input/joystick/iforce
        "iforce"
        "iforce-serio"
        "iforce-usb"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/interact.c
        "interact"
        # https://docs.kernel.org/input/joydev/joystick.html
        # https://github.com/torvalds/linux/blob/master/drivers/input/joydev.c
        "joydev"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/joydump.c
        "joydump"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/magellan.c
        "magellan"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/psxpad-spi.c
        "psxpad-spi"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/pxrc.c
        # https://github.com/torvalds/linux/blob/master/drivers/hid/hid-pxrc.c
        "pxrc"
        "hid-pxrc"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/qwiic-joystick.c
        "qwiic-joystick"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/sidewinder.c
        "sidewinder"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/spaceball.c
        "spaceball"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/spaceorb.c
        "spaceorb"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/stinger.c
        "stinger"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/tmdc.c
        "tmdc"
        # https://github.com/torvalds/linux/blob/master/drivers/usb/misc/trancevibrator.c
        "trancedriver"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/turbografx.c
        "turbografx"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/twidjoy.c
        "twidjoy"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/walkera0701.c
        "walkera0701"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/warrior.c
        "warrior"
        # https://github.com/torvalds/linux/blob/master/drivers/input/joystick/zhenhua.c
        "zhenhua"


        # Remote controls
        "rc-adstech-dvb-t-pci"
        "rc-alink-dtu-m"
        "rc-anysee"
        "rc-apac-viewcomp"
        "rc-astrometa-t2hybrid"
        "rc-asus-pc39"
        "rc-asus-ps3-100"
        "rc-ati-tv-wonder-hd-600"
        "rc-ati-x10"
        "rc-avermedia"
        "rc-avermedia-a16d"
        "rc-avermedia-cardbus"
        "rc-avermedia-dvbt"
        "rc-avermedia-m135a"
        "rc-avermedia-m733a-rm-k6"
        "rc-avermedia-rm-ks"
        "rc-avertv-303"
        "rc-azurewave-ad-tu700"
        "rc-beelink-gs1"
        "rc-beelink-mxiii"
        "rc-behold"
        "rc-behold-columbus"
        "rc-budget-ci-old"
        "rc-cinergy"
        "rc-cinergy-1400"
        "rc-ct-90405"
        "rc-d680-dmb"
        "rc-delock-61959"
        "rc-dib0700-nec"
        "rc-dib0700-rc5"
        "rc-digitalnow-tinytwin"
        "rc-digittrade"
        "rc-dm1105-nec"
        # https://github.com/torvalds/linux/blob/master/drivers/media/pci/dm1105/dm1105.c
        "dm1105"
        "rc-dntv-live-dvb-t"
        "rc-dntv-live-dvbt-pro"
        "rc-dreambox"
        "rc-dtt200u"
        "rc-dvbsky"
        "rc-dvico-mce"
        "rc-dvico-portable"
        "rc-em-terratec"
        "rc-encore-enltv"
        "rc-encore-enltv2"
        "rc-encore-enltv-fm53"
        "rc-evga-indtube"
        "rc-eztv"
        "rc-flydvb"
        "rc-flyvideo"
        "rc-fusionhdtv-mce"
        "rc-gadmei-rm008z"
        "rc-geekbox"
        "rc-genius-tvgo-a11mce"
        "rc-gotview7135"
        "rc-hauppauge"
        "rc-hisi-poplar"
        "rc-hisi-tv-demo"
        "rc-imon-mce"
        "rc-imon-pad"
        "rc-imon-rsc"
        "rc-iodata-bctv7e"
        "rc-it913x-v1"
        "rc-it913x-v2"
        "rc-kaiomy"
        "rc-khadas"
        "rc-khamsin"
        "rc-kworld-315u"
        "rc-kworld-pc150u"
        "rc-kworld-plus-tv-analog"
        "rc-leadtek-y04g0051"
        "rc-lme2510"
        "rc-loopback"
        "rc-manli"
        "rc-mecool-kiii-pro"
        "rc-mecool-kii-pro"
        "rc-medion-x10"
        "rc-medion-x10-digitainer"
        "rc-medion-x10-or2x"
        "rc-minix-neo"
        "rc-msi-digivox-ii"
        "rc-msi-digivox-iii"
        "rc-msi-tvanywhere"
        "rc-msi-tvanywhere-plus"
        "rc-mygica-utv3"
        "rc-nebula"
        "rc-nec-terratec-cinergy-xs"
        "rc-norwood"
        "rc-npgtech"
        "rc-odroid"
        "rc-pctv-sedna"
        "rc-pine64"
        "rc-pinnacle-color"
        "rc-pinnacle-grey"
        "rc-pinnacle-pctv-hd"
        "rc-pixelview"
        "rc-pixelview-002t"
        "rc-pixelview-mk12"
        "rc-pixelview-new"
        "rc-powercolor-real-angel"
        "rc-proteus-2309"
        "rc-purpletv"
        "rc-pv951"
        "rc-rc6-mce"
        "rc-real-audio-220-32-keys"
        "rc-reddo"
        "rc-siemens-gigaset-rc20"
        "rc-snapstream-firefly"
        "rc-streamzap"
        "rc-su3000"
        "rc-tanix-tx3mini"
        "rc-tanix-tx5max"
        "rc-tbs-nec"
        "rc-technisat-ts35"
        "rc-technisat-usb2"
        "rc-terratec-cinergy-c-pci"
        "rc-terratec-cinergy-s2-hd"
        "rc-terratec-cinergy-xs"
        "rc-terratec-slim"
        "rc-terratec-slim-2"
        "rc-tevii-nec"
        "rc-tivo"
        "rc-total-media-in-hand"
        "rc-total-media-in-hand-02"
        "rc-trekstor"
        "rc-tt-1500"
        "rc-twinhan1027"
        "rc-twinhan-dtv-cab-ci"
        "rc-vega-s9x"
        "rc-videomate-m1f"
        "rc-videomate-s350"
        "rc-videomate-tv-pvr"
        "rc-videostrong-kii-pro"
        "rc-wetek-hub"
        "rc-wetek-play2"
        "rc-winfast"
        "rc-winfast-usbii-deluxe"
        "rc-x96max"
        "rc-xbox-360"
        "rc-xbox-dvd"
        "rc-zx-irdec"
        # https://github.com/torvalds/linux/tree/master/drivers/media/rc
        "ati_remote"
        "ati_remote2"
        "ene_ir"
        "fintek-cir"
        "igorplugusb"
        "iguanair"
        "imon"
        "imon_raw"
        "ir-imon-decoder"
        "ir-jvc-decoder"
        # https://github.com/torvalds/linux/blob/master/drivers/media/i2c/ir-kbd-i2c.c
        "ir-kbd-i2c"
        "ir-mce_kbd-decoder"
        "ir-nec-decoder"
        "ir-rc5-decoder"
        "ir-rc6-decoder"
        "ir-rcmm-decoder"
        "ir-sanyo-decoder"
        "ir-sharp-decoder"
        "ir-sony-decoder"
        # https://github.com/torvalds/linux/blob/master/drivers/usb/serial/ir-usb.c
        "ir-usb"
        "ir_toy"
        "ir-xmp-decoder"
        "ite-cir"
        "mceusb"
        "nuvoton-cir"
        "serial_ir"
        "streamzap"
        "ttusbir"
        "winbond-cir"
        "xbox_remote"


        # legacy digital cameras (pre-2010)
        # note this often refers to point-and-shoot digital cameras
        # predating usb webcams, e.g. Kodak EZ200, Fujifilm FinePix F402, etc.
        # https://www.linuxtv.org/wiki/index.php/install gspca_devices
        "gspca_benq"
        "gspca_conex"
        "gspca_cpia1"
        "gspca_dtcs033"
        "gspca_etoms"
        "gspca_finepix"
        "gspca_gl860"
        "gspca_jeilinj"
        "gspca_jl2005bcd"
        "gspca_kinect"
        "gspca_konica"
        "gspca_m5602"
        "gspca_main"
        "gspca_mars"
        "gspca_mr97310a"
        "gspca_nw80x"
        "gspca_ov519"
        "gspca_ov534"
        "gspca_ov534_9"
        "gspca_pac207"
        "gspca_pac7302"
        "gspca_pac7311"
        "gspca_se401"
        "gspca_sn9c2028"
        "gspca_sn9c20x"
        "gspca_sonixb"
        "gspca_sonixj"
        "gspca_spca1528"
        "gspca_spca500"
        "gspca_spca501"
        "gspca_spca505"
        "gspca_spca506"
        "gspca_spca508"
        "gspca_spca561"
        "gspca_sq905"
        "gspca_sq905c"
        "gspca_sq930x"
        "gspca_stk014"
        "gspca_stk1135"
        "gspca_stv0680"
        "gspca_stv06xx"
        "gspca_sunplus"
        "gspca_t613"
        "gspca_topro"
        "gspca_touptek"
        "gspca_tv8532"
        "gspca_vc032x"
        "gspca_vicam"
        "gspca_xirlink_cit"
        "gspca_zc3xx"
        "dsbr100"
        "radio-keene"
        "radio-ma901"
        "radio-maxiradio"
        "radio-mr800"
        "radio-shark"
        # https://github.com/torvalds/linux/blob/master/drivers/media/radio/radio-shark2.c
        "shark2"
        "radio-si470x-common"
        "radio-si470x-i2c"
        "radio-si470x-usb"
        "radio-tea5764"
        "saa7706h"

        # act_pedit COW exploit (CVE-2026-46331)
        "act_pedit"
      ];

      # SecureBlue sysctl hardening
      environment.etc."sysctl.d/55-hardening.conf".text = ''
        # SPDX-FileCopyrightText: Copyright 2025-2026 The Secureblue Authors
        #
        # SPDX-License-Identifier: Apache-2.0

        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv4.tcp_syncookies = 1

        # https://docs.kernel.org/networking/ip-sysctl.html
        # https://datatracker.ietf.org/doc/html/rfc1337
        net.ipv4.tcp_rfc1337 = 1

        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv4.icmp_echo_ignore_broadcasts = 1

        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv4.icmp_ignore_bogus_error_responses = 1

        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv4.icmp_echo_ignore_all = 1
        net.ipv6.icmp.echo_ignore_all = 1

        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv4.tcp_timestamps = 0

        # Enable IP spoofing protection, turn on source route verification
        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv4.conf.all.rp_filter = 1
        net.ipv4.conf.default.rp_filter = 1

        # Disable ICMP Redirect Acceptance
        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv4.conf.*.send_redirects = 0
        net.ipv4.conf.*.accept_redirects = 0
        net.ipv6.conf.*.accept_redirects = 0

        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv4.conf.*.shared_media = 0

        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv4.conf.*.arp_filter = 1

        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv4.conf.*.arp_ignore = 2

        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv4.conf.all.drop_gratuitous_arp = 1

        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv4.conf.*.accept_source_route = 0
        net.ipv6.conf.*.accept_source_route = 0

        # Enable ipv6 privacy extension
        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv6.conf.all.use_tempaddr = 2
        net.ipv6.conf.default.use_tempaddr = 2

        # Enable Log Spoofed Packets, Source Routed Packets, Redirect Packets
        # https://docs.kernel.org/networking/ip-sysctl.html
        net.ipv4.conf.all.log_martians = 1
        net.ipv4.conf.default.log_martians = 1

        # https://docs.kernel.org/admin-guide/sysctl/net.html#bpf-jit-harden
        net.core.bpf_jit_harden = 2

        # https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
        #
        # Note: in addition to restricting ptrace using Yama, secureblue also restricts
        # ptrace access using SELinux. In particular, `ujust set-ptrace` offers three
        # possible states for ptrace access (independent of the value of `ptrace_scope`):
        # * enabled: no additional ptrace restrictions beyond those set by Yama.
        # * container-only: ptrace is only available to processes in the container domain.
        # * disabled: all processes are denied ptrace access.
        kernel.yama.ptrace_scope = 1

        # https://docs.kernel.org/admin-guide/sysctl/kernel.html#unprivileged-bpf-disabled
        kernel.unprivileged_bpf_disabled = 1

        # https://docs.kernel.org/admin-guide/sysrq.html
        kernel.sysrq = 0

        # https://docs.kernel.org/admin-guide/sysctl/kernel.html#perf-event-paranoid
        kernel.perf_event_paranoid = 3

        # https://docs.kernel.org/admin-guide/sysctl/kernel.html#kptr-restrict
        kernel.kptr_restrict = 2

        # https://docs.kernel.org/admin-guide/sysctl/kernel.html#dmesg-restrict
        kernel.dmesg_restrict = 1

        # https://docs.kernel.org/admin-guide/sysctl/kernel.html#oops-limit
        kernel.oops_limit=100

        # https://docs.kernel.org/admin-guide/sysctl/kernel.html#warn-limit
        kernel.warn_limit=100

        # https://docs.kernel.org/admin-guide/sysctl/kernel.html#panic
        kernel.panic=-1

        # https://docs.kernel.org/admin-guide/sysctl/fs.html#suid-dumpable
        fs.suid_dumpable = 0

        # https://docs.kernel.org/admin-guide/sysctl/fs.html#protected-regular
        fs.protected_regular = 2

        # https://docs.kernel.org/admin-guide/sysctl/fs.html#protected-fifos
        fs.protected_fifos = 2

        # https://docs.kernel.org/admin-guide/sysctl/fs.html#protected-hardlinks
        # Default in Fedora, including for runtime audit
        fs.protected_hardlinks = 1

        # https://docs.kernel.org/admin-guide/sysctl/fs.html#protected-symlinks
        # Default in Fedora, including for runtime audit
        fs.protected_symlinks = 1

        # https://lkml.org/lkml/2019/4/15/890
        dev.tty.ldisc_autoload = 0

        # Restrict userfaultfd to CAP_SYS_PTRACE
        # https://docs.kernel.org/admin-guide/sysctl/vm.html#unprivileged-userfaultfd
        vm.unprivileged_userfaultfd = 0

        # Prevent kernel info leaks in console during boot.
        # https://docs.kernel.org/admin-guide/sysctl/kernel.html#printk
        kernel.printk = 3 3 3 3

        # Disables kexec which can be used to replace the running kernel.
        # https://docs.kernel.org/admin-guide/sysctl/kernel.html#kexec-load-disabled
        kernel.kexec_load_disabled = 1

        # Disable core dump
        # https://docs.kernel.org/admin-guide/sysctl/kernel.html#core-pattern
        kernel.core_pattern = |/bin/false

        # Disable io_uring
        # https://lore.kernel.org/lkml/20230629132711.1712536-1-matteorizzo@google.com/T/
        # https://security.googleblog.com/2023/06/learnings-from-kctf-vrps-42-linux.html
        # https://docs.kernel.org/admin-guide/sysctl/kernel.html#io-uring-disabled
        kernel.io_uring_disabled = 2

        # Improve ALSR effectiveness for mmap.
        # https://docs.kernel.org/admin-guide/sysctl/vm.html#mmap-rnd-bits
        vm.mmap_rnd_bits = 32
        vm.mmap_rnd_compat_bits = 16

        # https://docs.kernel.org/admin-guide/sysctl/kernel.html#randomize-va-space
        # Default in Fedora, including for runtime audit
        kernel.randomize_va_space = 2

        # https://docs.kernel.org/admin-guide/sysctl/vm.html#mmap-min-addr
        # https://docs.kernel.org/admin-guide/sysctl/vm.html#max-map-count
        # Default in Fedora, including for runtime audit
        vm.mmap_min_addr = 65536
        vm.max_map_count = 1048576

        # from KSPP (https://kspp.github.io/Recommended_Settings)
        dev.tty.legacy_tiocsti = 0

        # from kernel-hardening-checker
        net.ipv6.conf.all.accept_ra = 0
        net.ipv6.conf.default.accept_ra = 0
      '';
  };
}
