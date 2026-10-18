# Hardening

What's actually enforced on these hosts, what it costs, and where it stops. All declarative, so none of it is a runtime tweak to remember. A change is a rebuild.

## What runs where

| Control | framework16 | vps | homelabvm | publicvm | anotherpublicvm |
| --- | --- | --- | --- | --- | --- |
| Kernel lockdown | integrity | confidentiality | confidentiality | confidentiality | confidentiality |
| Kernel params and module blacklist | yes | yes | yes | yes | yes |
| Runtime module lock | yes | yes | yes | yes | yes |
| `security.protectKernelImage` | yes | yes | yes | yes | yes |
| SecureBlue sysctl set | yes | yes | yes | yes | yes |
| Systemd service hardening | yes | yes | yes | yes | yes |
| No SUID, run0 instead of sudo | yes | yes | yes | yes | yes |
| `/proc` with `hidepid=2` | yes | yes | yes | yes | yes |
| Fixed machine-id | yes | yes | yes | yes | yes |
| NTS time with chrony | yes | yes | yes | yes | yes |
| Random MAC addresses | yes | no | no | no | no |
| USBGuard | yes | no | no | no | no |
| PAM faillock | yes | no | no | no | no |
| SUID removal for `fusermount3` and `qemu-bridge-helper` | yes | no | no | no | no |
| Bluetooth service hardening | yes | no | no | no | no |
| CrowdSec | no | yes, as a container | no | no | no |

framework16 is the machine you carry around and plug random things into, so it gets USB device control, login lockout and MAC randomisation. The VMs are keys-only SSH servers where most of that would just get in the way.

## Kernel

framework16 runs `linuxPackages-cachyos-latest-zen4`. The VMs run mainline, since CachyOS lags behind on versions and its patchset buys nothing on a headless server.

Lockdown is on everywhere: `integrity` on the CachyOS laptop, `confidentiality` on the servers. The LSM list is set to `lockdown` by hand since NixOS drops it, and `module.sig_enforce=1` is unconditional.

### Kernel parameters

Mostly from SecureBlue.

- Speculative execution: `mitigations=auto`, `l1tf=full,force`, `l1d_flush=on`, `spectre_v2=on`, `ssbd=force-on`, `spec_store_bypass_disable=on`, `kvm-intel.vmentry_l1d_flush=always`, `kvm.mitigate_smt_rsb=1`, `tsx=off`, `pti=on`
- Heap and memory: `init_on_alloc=1`, `init_on_free=1`, `page_alloc.shuffle=1`, `slab_debug=FZ`, `slab_nomerge`, `hash_pointers=always`, `randomize_kstack_offset=on`, `proc_mem.force_override=ptrace`
- Legacy attack surface removal: `vdso32=0`, `vsyscall=none`
- IOMMU and DMA: `iommu=force`, `intel_iommu=on`, `amd_iommu=force_isolation`, `iommu.passthrough=0`, `iommu.strict=1`
- Confidential computing for KVM guests: `kvm_amd.sev=1`, `kvm_amd.sev_es=1`, `kvm_amd.sev_snp=1`
- Entropy: `random.trust_cpu=off`, `random.trust_bootloader=off`, `extra_latent_entropy`, `rd.shell=0`, `rd.emergency=halt`
- Noise reduction: `quiet`, `loglevel=0`, `systemd.ssh_auto=no`
- framework16 only: `abmlevel=0`, `amdgpu.sg_display=0`

None of it's free. The mitigation set, the slab zeroing options and `slab_nomerge` cost real performance in memory heavy work and in games, and the zeroing options cost memory on top of that. `tsx=off` hard disables Intel TSX. `vdso32=0` drops the legacy 32 bit vDSO ABI, `vsyscall=none` drops the legacy vsyscall page. `amd_iommu=force_isolation` with `iommu.passthrough=0` puts every device in its own IOMMU domain. `random.trust_cpu=off` leaves only the other entropy sources.

### Module blacklist

Roughly 760 modules are blocked: unused network protocols (DCCP, SCTP, TIPC, AX.25, RDS, ATM, batman-adv), IPsec and l2tp, Sun RPC, NFS, CIFS, GFS2, 9p, ceph, a long tail of legacy filesystems, firewire and Thunderbolt, GNSS, CDROM, DVB and TV tuners, remote controls, joystick and gameport drivers, GPIB, parallel and floppy, CAN bus, RDMA, 6LoWPAN, automotive Ethernet PHYs, test and debug modules, netconsole, and `ath_pci`. Two are there for recent kernel exploits: `act_pedit` (CVE-2026-46331, the OpenVPN CONFIG_TUN bug) and `openvswitch` (the OVSWrap issue).

Bluetooth is left alone. `ath_pci` goes because the laptop uses `mt7921e`.

With those gone, kernel side NFS, CIFS, 9p and squashfs mounts don't exist. Userspace implementations still work, so gvfs for SMB and MTP are fine.

### Runtime module lock

`security.lockKernelModules` is true everywhere, so once you boot, nothing else loads. framework16 carries a long `boot.kernelModules` list preloading what it needs: storage, DM crypto, amdgpu, the SOF audio stack, Bluetooth, mt76 wifi, nftables, KVM, the Framework EC and HID. New hardware means extending that list. Same reason the VMs need a built in virtio SCSI controller and network card, since a module loaded after boot arrives too late for root or networking.

## sysctl

These land in `/etc/sysctl.d/65-hardening.conf`. The SecureBlue set plus a few of our own.

Network: SYN cookies, RFC 1337 strict ICMP, broadcast and bogus ICMP ignored, `icmp_echo_ignore_all` on v4 and v6, TCP timestamps off, strict `rp_filter`, redirects and source routes both rejected and not sent, `arp_filter=1`, `arp_ignore=2`, gratuitous ARP dropped, martian logging on, IPv6 privacy extensions, `bpf_jit_harden=2`, `accept_ra=0`.

Kernel: `yama.ptrace_scope=1`, `unprivileged_bpf_disabled=1`, `sysrq=0`, `perf_event_paranoid=3`, `kptr_restrict=2`, `dmesg_restrict=1`, `oops_limit=100`, `warn_limit=100`, `panic=-1`, `printk=3 3 3 3`, `kexec_load_disabled=1`, `core_pattern=|/bin/false`, `io_uring_disabled=2`, `randomize_va_space=2`, `mmap_rnd_bits=32`, `mmap_rnd_compat_bits=16`, `mmap_min_addr=65536`, `suid_dumpable=0`, `protected_regular=2`, `protected_fifos=2`, `protected_hardlinks=1`, `protected_symlinks=1`, `ldisc_autoload=0`, `legacy_tiocsti=0`, `unprivileged_userfaultfd=0`, `vm.max_map_count=1048576`.

So `ping` doesn't work on either family, though other ICMP types still pass so path MTU discovery keeps working. `io_uring` is gone system wide, not just for unprivileged users. No core dumps anywhere. `perf` needs privileges and eBPF profilers refuse. `yama.ptrace_scope=1` stops you attaching to processes you didn't start, which covers anything another process launched. `kexec` is gone, so a new kernel needs a reboot. `dmesg` is empty for an unprivileged user.

`accept_ra=0` stops IPv6 addresses being learned from router advertisements, needed on the forwarding hosts, and `use_tempaddr=2` rotates the address on a timer. `rp_filter` is strict on both `all` and `default` and the kernel takes the higher, so a daemon relaxing it on its own interface, Tailscale say, gets overridden. `tcp_timestamps=0` and `tcp_rfc1337=1` are stricter than some middleboxes expect.

`kernel-hardening-checker` and `lynis` are installed everywhere and are the quickest way to confirm a setting survived a nixpkgs bump.

## No SUID

`sudo` is gone. `security.run0` is enabled with `wheelNeedsPassword = true` and `enableSudoAlias = true`, and a bunch of wrappers are forced to stop being SUID:

| Binary | Replacement |
| --- | --- |
| `su`, `newgrp`, `sg` | none, use `run0` |
| `mount`, `umount` | none, shell aliases map them to `run0` |
| `pkexec` | none |
| `fusermount`, `fusermount3` | `cap_sys_admin=ep` |
| `qemu-bridge-helper` | none |
| `unix_chkpwd` | `cap_dac_read_search,cap_audit_write=ep` |
| `gamemoded` | `cap_sys_nice=ep` |
| `gnome-keyring-daemon` | `cap_ipc_lock=ep` |
| `newuidmap` | `cap_setuid=ep` |
| `newgidmap` | `cap_setgid=ep` |

`nosuid` is set on `/`, `/persist` and `/boot`, plus `/nix` on the VMs. framework16 leaves `/nix` exec only on purpose, since `nosuid` there would take the capabilities above with it. And the kernel ignores file capabilities on a `nosuid` filesystem, so those capabilities do nothing on the VMs and FUSE is unavailable. Rootless podman doesn't care either way, it uses native overlay rather than `fuse-overlayfs`.

`/home/<user>/.cache` is its own 4 GB tmpfs mounted `noexec`, `nodev` and `nosuid`, mode 0700, hardcoded `uid=1000`. Jails never see it. Each mounts a separate empty tmpfs at `~/.cache`, so caches don't get shared between sandboxes or with unsandboxed apps.

`sudo` still exists as a symlink to `run0` and doesn't understand sudo options. Anything that leaned on the SUID bit, `su` for a user switch, `pkexec` for polkit authentication, or a working FUSE helper, has no equivalent here.

## PAM faillock

Laptop only. `pam_faillock` is wired into `login`, `sudo`, `su`, `passwd`, `sshd`, `polkit-1` and `systemd-run0`, with `deny = 3`, `fail_interval = 900`, `unlock_time = 1800`, `root_unlock_time = 1800`, `even_deny_root` and `audit`. State lives in `/var/run/faillock`, a tmpfs, so reboots wipe the counters.

Three failures and you're locked out for thirty minutes. The polkit stack shares the counter with login, and `even_deny_root` means getting back in as root needs the console.

## USBGuard

Laptop only. `implicitPolicyTarget = "block"`, `insertedDevicePolicy = "apply-policy"`, `presentDevicePolicy = "apply-policy"`, `presentControllerPolicy = "keep"`. Rules are a sops secret at `/run/secrets/usbguard-rules.conf`, root owned, mode 0644, and changing it restarts `usbguard.service`. Service and D-Bus interface both get `NoNewPrivileges`, `MemoryDenyWriteExecute`, `RestrictSUIDSGID` and `SystemCallArchitectures=native`.

Anything without a rule gets blocked, so every USB stick, phone, headset, camera, YubiKey and printer needs a rule first. Devices already enumerated at boot match on the `present` policy, so a bad rule there can knock a device out before you've logged in. The built in keyboard survives on Framework hardware because it's on the internal PS/2 and platform EC path. A rule blocking the wrong controller isn't recoverable from the same machine though. The real fix goes into the encrypted secrets file, so it's applied by editing secrets and rebuilding. `usbguard list-devices` and `usbguard allow-device` are only there for diagnosis.

## Systemd service hardening

Most services get `ProtectSystem=strict`, `ProtectHome`, `NoNewPrivileges`, `ProtectKernelLogs`, `ProtectControlGroups`, `ProtectHostname`, `LockPersonality`, `RestrictRealtime`, `UMask=0077`, `SystemCallArchitectures=native` and a narrowed `RestrictAddressFamilies`. NetworkManager and Bluetooth also get `DevicePolicy=closed` with an explicit allow list, `ProtectProc=invisible`, `ProcSubset=pid`, `PrivateTmp`, `PrivateIPC`, `PrivateBPF`, `RestrictNamespaces`, a `SystemCallFilter` and `MemoryDenyWriteExecute`. polkit, wpa_supplicant, fwupd, dbus-broker, power-profiles-daemon, upower, dconf, lactd, systemd-rfkill, both ask-password units and the plymouth units are in there too, some with a lighter take.

Upstream defaults still apply, so services keep working. Hardening stops where the list stops, so anything unnamed gets stock systemd hardening. `udisks2` isn't hardened because making it strict broke `/run/media` and it stopped mounting anything. `journald`, `logind`, `pipewire`, `wireplumber` and `gnome-keyring` aren't hardened either.

There are a few `mkForce` calls, all deliberate. Bluetooth needs `ProtectKernelModules` and `ProtectKernelTunables`, speechd is forced off, the SUID removals above are forced to non setuid.

NetworkManager gets `DevicePolicy=closed` with only `/dev/net/tun` allowed, which is the only reason VPN and Tor through NetworkManager work at all. It also carries `NoNewPrivileges` and `MemoryDenyWriteExecute`, so there's no JIT inside it and VPN plugins can't become root.

The approach has been to add the hardening, see what breaks, then back off that one directive. Expect to do it again on the next nixpkgs bump.

## Network

Firewall on, closed by default. The VPS allows TCP 80, 443, 3306 and 42712 plus UDP 51820, 21820, 42712 and 63536. homelabvm allows TCP 22, 80 and 443. publicvm and anotherpublicvm open nothing beyond SSH.

DNS goes through dnscrypt-proxy on `127.0.0.1:53`, resolvers from a fixed list: quad9 with filtering, adguard, a Czech resolver and cloudflare. No split DNS, no per app filtering. Anything ignoring `/etc/resolv.conf` walks straight past it, which covers containers with hardcoded DNS and apps with built in DoH.

SSH is keys only. `PermitRootLogin=no`, `MaxAuthTries=3`, `LoginGraceTime=30`, `MaxStartups=10:30:100`, `DisableForwarding=yes`, `PermitTunnel=no`, `ClientAliveInterval=300`, `PerSourcePenalties=crash:3600s authfail:3600s max:86400s`. `AllowUsers` is the login user only, so `deploy` and `guest` are reachable with `run0 su` and never over SSH. `DisableForwarding=yes` also kills `ssh -L`, `-R` and `-D`, so anything bound to localhost on a VM gets reached through Tailscale or the reverse proxy.

CrowdSec runs on the VPS as a rootless podman quadlet in the `deploy` home. It reads the traefik logs from a mounted volume and keeps its LAPI on `127.0.0.1:8080`. IP metrics export is off but the LAPI is on, so the daemon still makes outbound calls. See [CONTAINERS.md](CONTAINERS.md).

MAC addresses are randomised on wifi and ethernet, and wifi scans randomise too. That rules out anything identifying the machine by hardware address, like 802.1X style enterprise wifi or a router side allowlist.

Firefox turns DNS over HTTPS off and locks the setting, since the VPN handles resolution.

## Disabled services

| Service | Reason | Consequence |
| --- | --- | --- |
| `avahi` | mDNS and DNS-SD advertise the machine on the local network | no automatic discovery of printers, projectors or shares |
| `geoclue2` | location services | nothing reports your location, apps that need it refuse |
| `accounts-daemon` | not needed, systemd units start on demand | nothing |
| `speechd` | unused speech dispatcher | forced off, anything expecting it fails |
| `modemmanager` | no cellular hardware | nothing |
| `timesyncd` | replaced by chrony with NTS | `timedatectl` shows `n/a` for NTP |
| `sudo` | replaced by run0 | see the No SUID section |

## Time

chrony with NTS, `authselectmode require`, five servers across Cloudflare, NL, SE, PT and DK, `minsources 3`, `makestep 1.0 3`, command port off so nothing can query or change it remotely. chronyd itself is hardened with `ProtectSystem=full` and a narrowed address family list.

NTS does a certificate exchange over the network, so a machine with no connectivity at boot has no trusted time until the link is up. Captive portals and filtering middleboxes both look like a clock problem. `minsources 3` means chrony sits unsettled while fewer than three sources agree.

## Filesystem, impermanence and boot

`/` is a tmpfs: 25% of RAM on the laptop, 50% on the VMs. Only `/persist` survives, and `/nix` is a bind mount from `/persist/nix` with `exec`.

Persisting system wide: NetworkManager connections, bluetooth state on the laptop, the Nix store, sbctl keys, Tailscale, `/var/lib/nixos`, and on the VMs the four SSH host keys.

Persisting in the laptop home: `Music`, `Pictures`, `Documents`, `Projects`, `Videos`, `programs`, `retro-game-roms`, `Templates`, rustup toolchains and hashes, a pile of app and tool directories, `.ssh`, `.config/sops`, `.config/libvirt`, `.config/mozilla`, `.config/dconf`, `.config/Proton`, `.config/Code`, `.local/share/Steam`, `.local/share/keyrings`, `.local/state/wireplumber` and `.wakatime`.

Server homes keep a shorter list: `.local/bin`, `.local/share/containers`, `.local/share/zoxide`, `containers`, `.ssh` and `.config/sops`.

Everything else resets on reboot, including `Downloads`, `Desktop`, most of `~/.config` and `~/.local/share/Trash`. New software needs its state directory added.

`hideMounts = true` on both layers. The persistence mounts are slave mounts, so anything appearing under `/persist` later on the host doesn't propagate into other mount namespaces. It isn't hiding data though: a container or jail that explicitly bind mounts a persistence path still gets the contents.

Secure Boot on the laptop runs through Limine, with checksum validation and `panicOnChecksumMismatch`, and `sbctl` handles enrolment. Keys need enrolling before the laptop boots unattended, so a fresh install comes up once for that. The VMs use systemd-boot with the editor disabled and no Secure Boot, which is why the README asks you to turn it off in the Proxmox VM BIOS.

The flip side of a clean `/` is no crash kernel, no old initrds, no forensic leftovers. Post mortem debugging gets harder.

## Users and privilege separation

One login user, in `wheel` and `networkmanager`, plus `tor` on framework16. `mutableUsers = false`, zsh, password from a sops secret.

Unprivileged container users with fixed UIDs: `deploy` (1001) on vps, homelabvm and publicvm, `guest` (1002) on publicvm and anotherpublicvm. Both have `linger = true`, so rootless podman survives a logout.

virt-manager isn't in `libvirtd`. It uses `qemu://session`, which is rootless, so group membership never gets you rootful QEMU.

polkit is enabled so GUI apps can still do the handful of things needing authorisation.

The password hash is a sops secret at `/persist/etc/secrets/password-hash`, root owned, mode 0400. It's the only secret needed before anything else works.

Root is one password prompt away and run0 always asks, so there's no unattended escalation path and an unattended rebuild isn't possible. run0 goes through systemd, which is why it works over SSH using the wall password prompt, and why `systemd-ask-password-wall` gets hardened rather than removed.

User namespaces and rootless containers are the boundary for anything untrusted. The `guest` user exists so third party game servers and CI jobs can't read files `deploy` owns.

## Known gaps

No MAC. NixOS has no stable AppArmor or SELinux, so there are no path rules, no file labels and no per app filesystem policy beyond what the jails bind. AppArmor's the first thing to add once it stabilises.

No seccomp filtering in the jails. jail.nix ships an `add-seccomp` combinator and it goes unused, so a jailed app can make any syscall the kernel allows. See [SANDBOXING.md](SANDBOXING.md).

No per app network policy. Jails with network share the host namespace, so there's no egress control and no way to say one app may only talk to one server.

`ip_unprivileged_port_start` is lowered to 80 on homelabvm and vps. The host config calls that a security degradation, and it is one, since an unprivileged user can bind ports below 1024. Both hosts also have IPv4 and IPv6 forwarding on for the tunnel.

`HardeningEnvironmentLockdown` is a placeholder. The module amounts to a no-op with a TODO, so shell rc files and `~/.config/environment.d` stay writable at runtime. The plan was to bind them read only from the Home Manager store after activation.

The hardened memory allocator is off. `environment.memoryAllocator.provider = "graphene-hardened-light"` is commented out because it broke browsers, so malloc hardening is whatever nixpkgs ships.

faillock, USBGuard and MAC randomisation are absent on the servers.

Much of this leans on hardware assumptions, IOMMU isolation, the blacklist, the preloaded module list, and it's all tied to this laptop and these VMs. New hardware means going back through it.

Rootless podman depends on user namespaces. A future kernel or sysctl change restricting unprivileged namespaces stops every container on every host at once.