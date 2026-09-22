My hardened dendritic NixOS configuration for my laptop & VMs. Uses CachyOS kernel, has lots of hardening options, uses modern Wayland, and includes lots of tools and apps.

- **Config Layout:** Dendritic, everything is modular
- **Secrets:** Managed by sops, using post-quantum age encryption

## Framework16
  - **WM:** niri
  - **Shell:** Noctalia
  - **Browser:** Declarative Firefox managed via Home Manager and Enterprise policies (No AI, no telemetry, anti-fingerprinting, arkenfox included, UBlock Origin, Bitwarden, and extra user.js firefox hardening)
  - **Theme**: Nord managed through Stylix + zsh-syntax-highlighing + matching Firefox them e extension
  - **Gaming:** Steam, MangoHud, GameMode, Gamescope, Anime Game Launcher on Linux (AAGL), ProtonPlus (to install Proton versions)
  - **Virtualization:** rootless podman + user session virt-manager (QEMU)
  - **Bootloader:** Limine with Secure Boot
  - **File System:** ext4 protected by LUKS
  - **Kernel:** CachyOS-latest-zen4
  - **Jail.nix:** GUI (and some CLI) apps are sandboxed and have least-privilege access to system resources and files where possible.
  - **Impermanence:** Only select directories and files are kept on each reboot, / is a tmpfs, and the system remains clean.
  - **Kernel Hardening:** SecureBlue module blacklist, SecureBlue kernel flags and some extras, locked kernel & kernel modules at runtime
  - **System Hardening:** SecureBlue sysctl options and some extras, NTS (Network Time Security), closed firewall, disabling unneccessary services, extensive systemctl hardening, USBGuard is implemented, PAM faillock is in use and locks after 3 wrong tries, DNSCrypt
  - **No SUID:** no SUID binaries at all, SUIDs replaced by capabilities or removed altogether, run0 instead of sudo, noexec on ~/.cache and /boot, nosuid on all filesystems
  - **Development:** Rust, Python(uv), C, Zed Editor, Ghidra
  - **Apps:** Tor Browser, OnlyOffice, Orca Slicer, Kdenlive, mpv, OBS, Obsidian, Gnome Calculator, Fedora Media Writer, Monero Wallet
  - **CLI/TUI:** Zsh with zsh-syntax-highlighting and theming, yazi, btop, htop, eza, fzf, opencode, bat, and common tools 
  
  The security part of this configuration is currently incomplete, as NixOS does not currently have stable MAC (Mandatory Access Control) support. Similar sandboxing is being done using jail.nix. Once AppArmor as well as apparmod.d will stabilize on NixOS, it will be implemented for maximum security.

## PublicVM, AnotherPublicVM, HomeLabVM & VPS
  - **Containers**: Rootless podman
  - **Users**: privileged user for management, unprivileged deploy/guest user for deployment
  - **Bootloader:** systemd-boot
  - **File System:** ext4
  - **Kernel:** CachyOS-latest
  - **No SUID:** no SUID binaries at all, SUIDs replaced by capabilities or removed altogether, run0 instead of sudo, noexec on ~/.cache and /boot, nosuid on all filesystems
  - **Impermanence:** Only select directories and files are kept on each reboot, / is a tmpfs, and the system remains clean.
  - **Kernel Hardening:** SecureBlue module blacklist, SecureBlue kernel flags and some extras, locked kernel & modules at runtime
  - **System Hardening:** SecureBlue sysctl options and some extras, NTS (Network Time Security), closed firewall, disabling unneccessary services, extensive systemctl hardening, DNSCrypt
  - **CLI/TUI:** Zsh with zsh-syntax-highlighting and theming, yazi, btop, htop, eza, fzf, bat, and common tools 

## Installation

Installation is done with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere). Every host has a disko layout in `modules/hosts/<host>/disko.nix`, and nixos-anywhere runs disko for you. This wipes the disk. `/` is a tmpfs and only `/persist` survives a reboot.

| Host | Disk | Login user | Secrets | SSH
| --- | --- | --- | --- | --- |
| `framework16` | `/dev/nvme0n1` (LUKS) | `csd4ni3l` | `modules/hosts/framework16/secrets.yml` | no |
| `vps` | `/dev/vda` | `user` | `modules/hosts/vps/secrets/*.yml` |  yes |
| `anotherpublicvm` | `/dev/sda` | `user` | `modules/hosts/anotherpublicvm/secrets/*.yml` | yes |
| `homelabvm` | `/dev/sda` | `user` | `modules/hosts/homelabvm/secrets/*.yml` | yes |
| `publicvm` | `/dev/sda` | `user` | `modules/hosts/publicvm/secrets/*.yml` | yes |

SSH root login is disabled in the final system, so you need root access on the target before installing: the provider's root login or console for the VMs, a NixOS installer ISO for framework16.

### Age keys

Secrets are managed by sops-nix. Every host decrypts with an age key stored at:

```
/persist/home/<user>/.config/sops/age/keys.txt
```

Generate a post-quantum key (needs age 1.3 or newer):

```
age-keygen -pq -o keys.txt
```

Add the public key (`age1pq...`) to the right `key_groups` entry in `.sops.yaml`, then re-encrypt every secrets file for that host:

```
sops updatekeys modules/hosts/vps/secrets/user.yml
sops updatekeys modules/hosts/vps/secrets/deploy.yml
```

framework16 keeps everything in one file, so there you only run `sops updatekeys modules/hosts/framework16/secrets.yml`.

Edit a secret with:

```
sops modules/hosts/vps/secrets/user.yml
```

The only value needed for boot is `password-hash`, the login password hash. (You can switch yescrypt to another mode if you want to). Make it with:

```
mkpasswd -m yescrypt
```

### Install

The target needs the age keys before the first boot, otherwise sops-nix cannot decrypt `password-hash`. Stage them in a directory that mirrors the target filesystem:

```
mkdir -p extra/persist/home/user/.config/sops/age
install -m600 keys.txt extra/persist/home/user/.config/sops/age/keys.txt
```

for each user of the host.

For example, for the `homelabvm` host:

```
nix run github:nix-community/nixos-anywhere -- \
  --flake .#vps \
  --extra-files ./extra \
  --chown /persist/home/user/.config/sops/age 1000:100 \
  --chown /persist/home/deploy/.config/sops/age 1001:100 \
  --target-host root@<address>
```

`--extra-files` is copied after disko mounts the new filesystem and before the reboot, so the key is already in `/persist` on first boot. Copied files are owned by root, and the user has to read the key as well, so `--chown` sets it to the user's UID, gid 100 (user group). Replace `.#vps` with the host you want, and add each user's keys into `extra` then use --chown `/persist/home/user/.config/sops/age UID:100` for each of them in the command.

framework16 uses `csd4ni3l` (feel free to change) and an encrypted disk. disko asks for the LUKS passphrase during the install:

```
nix run github:nix-community/nixos-anywhere -- \
  --flake .#framework16 \
  --extra-files ./extra \
  --chown /persist/home/csd4ni3l/.config/sops/age 1000:100 \
  --target-host root@<address>
```

framework16 boots with limine and Secure Boot. Enroll the generated keys in firmware (use `sbctl`) before you expect it to boot on its own. The target's SSH host key changes after install, so clear the old entry with `ssh-keygen -R <address>`.

### Proxmox VM Recommended/Tested Setup
- **BIOS: `OVMF (UEFI)` instead of `SeaBIOS`. (REQUIRED)**
- Machine: `q35`
- **Disable Secure Boot inside BIOS before booting, otherwise it won't work (or set it up properly, but i didn't) (REQUIRED)**
- **SCSI Controller: `Virtio SCSI Single` (REQUIRED for default setup with kernel module lock on)**
- Disks with `discard=on`
- QEMU Agent option ticked
- **Network Card Model: `Virtio (paravirtualized)` (REQUIRED for default setup with kernel module lock on)**


### Update VMs

For VMs, currently i could not make it work correctly, so for now:
- Login to VM through SSH
- git clone my repo and cd to it: `git clone https://git.csd4ni3l.hu/csd4ni3l/nixos-config && cd nixos-config`, or if you already have the repo, just `git pull`
- Run: `run0 nixos-rebuild switch --flake .#hostname --no-reexec --accept-flake-config`

### Update Framework16
just run the custom `rebuild` alias

## Mirrors

[![Forgejo](https://img.shields.io/badge/Forgejo-git.csd4ni3l.hu-1e90ff)](https://git.csd4ni3l.hu/csd4ni3l/nixos-config)
[![GitHub](https://img.shields.io/badge/GitHub-github.com-181717)](https://github.com/csd4ni3l/nixos-config)
[![Codeberg](https://img.shields.io/badge/Codeberg-codeberg.org-2185D0)](https://codeberg.org/csd4ni3l/nixos-config)
