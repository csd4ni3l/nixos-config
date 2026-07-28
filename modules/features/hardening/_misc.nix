{ pkgs, lib, ... }: {
  security.protectKernelImage = true;
  security.lockKernelModules = true;

  environment.systemPackages = with pkgs; [ kernel-hardening-checker usbguard-notifier lynis ];

  networking.modemmanager.enable = false;

  # TODO: figure out something cause this breaks browsers and stuff
  # environment.memoryAllocator.provider = "graphene-hardened-light";

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

  services.usbguard = {
    enable = true;

    implicitPolicyTarget = "block";
    insertedDevicePolicy = "apply-policy";
    presentDevicePolicy = "apply-policy";
    presentControllerPolicy = "keep";

    IPCAllowedUsers = [ "root" "csd4ni3l" ];
    IPCAllowedGroups = [ "wheel" ];
    dbus.enable = true;
  };

  boot.kernelParams = [
    "quiet"

    # NOTE: kernel parameters from secureblue
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
    "random.trust_cpu=off" # Disable CPU-based entropy sources, as it's not auditable and has resulted in vulnerabilities.
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
}
