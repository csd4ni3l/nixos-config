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

framework16 runs the Zen kernel, while the VMs run mainline, since Zen doesnt do much on a headless server.

Lockdown is on everywhere, set to `integrity` on the laptop and `confidentiality` on the servers. The LSM list is set to `lockdown` by hand since NixOS drops it, and `module.sig_enforce=1` is unconditional.

### Kernel parameters

Mostly from SecureBlue, covering speculative execution, heap zeroing, IOMMU isolation, KVM SEV/SNP, entropy and log noise. The exact list is in `modules/features/system/hardening/kernel.nix`.

All of it costs something. The mitigation set, the slab zeroing options and `slab_nomerge` hit performance in memory heavy work and in games, and the zeroing options cost memory on top of that. `tsx=off` hard disables Intel TSX. `vdso32=0` and `vsyscall=none` drop the legacy 32 bit vDSO and vsyscall interfaces. IOMMU isolation puts every device in its own domain, and `random.trust_cpu=off` leaves only the other entropy sources.

### Module blacklist

Roughly 760 modules are blocked, covering unused network protocols, IPsec, Sun RPC, NFS, CIFS, 9p, ceph, legacy filesystems, firewire, Thunderbolt, GNSS, TV tuners, joystick and gameport drivers, CAN bus, RDMA, and test and debug modules among others. Two are there for recent kernel exploits, `act_pedit` (CVE-2026-46331, the OpenVPN CONFIG_TUN bug) and `openvswitch` (the OVSWrap issue).

Bluetooth is left alone. `ath_pci` goes because the laptop uses `mt7921e`.

With those gone, kernel side NFS, CIFS, 9p and squashfs mounts don't exist. Userspace implementations still work, so gvfs for SMB and MTP are fine.

### Runtime module lock

`security.lockKernelModules` is true everywhere, so once you boot, nothing else loads. framework16 carries a long preload list covering storage, audio, GPU, wifi, firewall and the Framework EC. New hardware means extending that list, and the VMs need a built in virtio SCSI controller and network card for the same reason, since a module loaded after boot arrives too late for root or networking.

## sysctl

These land in `/etc/sysctl.d/65-hardening.conf`, the SecureBlue set plus a few of our own. The file has the full list, the effects worth knowing are:

- `ping` doesn't work on either family, though other ICMP types still pass so path MTU discovery keeps working.
- `io_uring` is gone system wide, not just for unprivileged users. Anything built on liburing fails.
- No core dumps anywhere, so a segfault leaves nothing for gdb.
- `perf` needs privileges and eBPF profilers refuse. Same for attaching to a process you didn't start.
- `kexec` is gone, so a new kernel needs a reboot.
- `dmesg` is empty for an unprivileged user.
- `rp_filter` is strict, and the kernel takes the higher of the `all` and per-interface values, so a daemon relaxing it on its own interface gets overridden.
- Some network settings are stricter than middleboxes expect, which can break things behind unusual routers.

`kernel-hardening-checker` and `lynis` are installed everywhere and are the quickest way to confirm a setting survived a nixpkgs bump.

## No SUID

`sudo` is gone. `run0` replaces it, always asks for the root password, and a set of SUID binaries is either stripped or demoted to file capabilities:

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
| `newuidmap`, `newgidmap` | `cap_setuid`/`cap_setgid=ep` |

`nosuid` is set on `/`, `/persist` and `/boot`, plus `/nix` on the VMs. framework16 leaves `/nix` exec only, since `nosuid` there would drop the capabilities above. And the kernel ignores file capabilities on a `nosuid` filesystem, so those capabilities do nothing on the VMs and FUSE is unavailable. Rootless podman doesn't care either way, it uses native overlay.

`~/.cache` is its own 4 GB tmpfs mounted `noexec`. Jails never see it, they each mount a private empty tmpfs instead.

`sudo` still exists as a symlink to `run0` and doesn't understand sudo options. Anything that leaned on the SUID bit has no equivalent here.

## PAM faillock

Laptop only. Three failed attempts on login, sudo, su, sshd, polkit or run0 locks you out for thirty minutes. The counters live in a tmpfs, so reboots clear them. Root recovery needs the console.

## USBGuard

Laptop only, block by default. Anything without a rule is refused, so every USB stick, phone, headset, camera, YubiKey and printer needs one before it works. The rules are a sops secret, so a fix goes through editing secrets and rebuilding rather than anything you can do from a running system.

Devices already enumerated at boot match a separate policy, which means a bad rule there can knock a device out before you've logged in. The built in keyboard survives on Framework hardware because it's on the internal platform path.

## Systemd service hardening

Most services get `ProtectSystem=strict`, `NoNewPrivileges`, `ProtectHome`, a narrowed address family list and `SystemCallArchitectures=native`. NetworkManager and Bluetooth get a closed device policy, `ProtectProc=invisible` and a syscall filter on top. polkit, fwupd, dbus-broker, upower, dconf and a few dozen others are in there too, some with a lighter take.

Upstream defaults still apply, so services keep working. Hardening stops where the list stops, so anything unnamed gets stock systemd hardening. `udisks2` isn't hardened because making it strict broke `/run/media` and it stopped mounting anything. `journald`, `logind`, `pipewire`, `wireplumber` and `gnome-keyring` aren't hardened either.

NetworkManager gets only `/dev/net/tun` allowed, which is the only reason VPN and Tor through it work at all. It also has no JIT and can't be escalated by a plugin.

The approach has been to add the hardening, see what breaks, then back off that one directive. Expect to do it again on the next nixpkgs bump.

## Network

Firewall on, closed by default. Only the VPS opens anything real, for the tunnel, the proxy and the panel. homelabvm allows web traffic. publicvm and anotherpublicvm open nothing beyond SSH.

DNS goes through dnscrypt-proxy with a fixed resolver list. No split DNS, no per app filtering. Anything ignoring `/etc/resolv.conf` walks straight past it, which covers containers with hardcoded DNS and apps with built in DoH.

SSH is keys only, with root login, password auth and forwarding all disabled. `AllowUsers` is the login user only, so `deploy` and `guest` are reachable with `run0 su` and never over SSH. No forwarding means anything bound to localhost on a VM gets reached through Tailscale or the reverse proxy instead.

CrowdSec runs on the VPS as a rootless podman quadlet, reading the proxy logs. See [CONTAINERS.md](CONTAINERS.md).

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

chrony with NTS, five servers, command port off so nothing can query or change it remotely.

NTS does a certificate exchange over the network, so a machine with no connectivity at boot has no trusted time until the link is up. Captive portals and filtering middleboxes both look like a clock problem.

## Filesystem, impermanence and boot

`/` is a tmpfs. Only `/persist` survives, and the Nix store lives inside it.

What persists is short and deliberate. System wide that's NetworkManager connections, the Nix store, Secure Boot keys, Tailscale, and on the VMs the SSH host keys. In your home it's the big directories like `Documents`, `Projects`, `Music` and `.ssh`, plus whatever app state needs keeping. Everything else resets on reboot, including `Downloads` and most of `~/.config`. New software needs its state directory added.

The persistence mounts are hidden slave mounts, so a container or jail only sees them if it explicitly asks. That isn't hiding data, a jail that binds a persistence path still gets the contents.

Secure Boot on the laptop runs through Limine with checksum validation, and keys need enrolling before it boots unattended, so a fresh install comes up once for that. The VMs use systemd-boot with the editor disabled and no Secure Boot, which is why the README asks you to turn it off in the Proxmox BIOS.

With a clean `/` there's no crash kernel, no old initrds and no forensic leftovers, which makes post mortem debugging harder.

## Users and privilege separation

One login user, in `wheel` and `networkmanager`. `mutableUsers = false`, zsh, password from a sops secret. The password hash is the only secret needed before anything else boots.

Container users are separate and unprivileged, with fixed UIDs and `linger` so their containers survive a logout. See [CONTAINERS.md](CONTAINERS.md) for which host runs which.

virt-manager isn't in `libvirtd`. It uses a rootless session, so group membership never gets you rootful QEMU.

Root is one password prompt away and run0 always asks, so there's no unattended escalation path and an unattended rebuild isn't possible. That also means it works over SSH, since run0 goes through systemd and can use the wall prompt.

User namespaces and rootless containers are the boundary for anything untrusted. The `guest` user exists so third party game servers and CI jobs can't read files `deploy` owns.

## Known gaps

No MAC. NixOS has no stable AppArmor or SELinux, so there's no path or label policy beyond what the jails bind. AppArmor's the first thing to add once it stabilises.

No seccomp filtering in the jails, so a jailed app can make any syscall the kernel allows. Namespaces and mounts are the only boundary. See [SANDBOXING.md](SANDBOXING.md).

No per app network policy. Jails with network share the host namespace, so there's no egress control.

`ip_unprivileged_port_start` is lowered to 80 on homelabvm and vps, so an unprivileged user can bind privileged ports. Both hosts also have IPv4 and IPv6 forwarding on for the tunnel. The host configs call this a security degradation themselves.

`HardeningEnvironmentLockdown` is a placeholder, so shell rc files stay writable at runtime. The plan was to bind them read only from the store after activation.

The hardened memory allocator is off because it broke browsers, so malloc hardening is whatever nixpkgs ships.

faillock, USBGuard and MAC randomisation are absent on the servers.

Much of this leans on hardware assumptions, so new hardware means going back through it.

Rootless podman depends on user namespaces. A future kernel or sysctl change restricting unprivileged namespaces stops every container on every host at once.
