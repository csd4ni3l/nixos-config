My hardened dendritic NixOS configuration for my laptop & VMs. The laptop runs the Zen kernel, the VMs run mainline. Lots of hardening options, modern Wayland, and plenty of tools and apps.

- **Config Layout:** Dendritic, everything is modular
- **Secrets:** Managed by sops, using post-quantum age encryption

## Documentation

The longer version of everything below lives in `docs/`. Worth reading if you want the why, not just the what.

| Doc | Covers |
| --- | --- |
| [docs/APPS.md](docs/APPS.md) | Every app on framework16 and every container on the VMs, whether it's sandboxed, and how it's set up |
| [docs/CLI.md](docs/CLI.md) | Shell, aliases, terminal, dev toolchain, privilege model, Nix setup, and how to rebuild |
| [docs/CONTAINERS.md](docs/CONTAINERS.md) | Every container, who runs it, the full port map, network wiring, and the known trade-offs |
| [docs/HARDENING.md](docs/HARDENING.md) | What's enforced per host, what it costs, and the list of things it doesn't cover |
| [docs/SANDBOXING.md](docs/SANDBOXING.md) | How jail.nix wraps apps, what each one can touch, and where the sandbox stops helping |

## Framework16
  - **WM:** niri
  - **Shell:** Dank Material Shell (DMS)
  - **Browser:** Declarative Firefox managed via Home Manager and Enterprise policies (No AI, no telemetry, anti-fingerprinting, arkenfox included, UBlock Origin, Bitwarden, and extra user.js firefox hardening)
  - **Theme**: Nord managed through Stylix + zsh-syntax-highlighting + matching Firefox theme extension
  - **Gaming:** Steam, MangoHud, GameMode, Gamescope, Anime Game Launcher on Linux (AAGL), ProtonPlus (to install Proton versions)
  - **Virtualization:** rootless podman + user session virt-manager (QEMU)
  - **Bootloader:** Limine with Secure Boot
  - **File System:** ext4 protected by LUKS
  - **Kernel:** Linux Zen
  - **Jail.nix:** GUI (and some CLI) apps are sandboxed and have least-privilege access to system resources and files where possible. See [docs/SANDBOXING.md](docs/SANDBOXING.md)
  - **Impermanence:** Only select directories and files are kept on each reboot, / is a tmpfs, and the system remains clean.
  - **Kernel Hardening:** SecureBlue module blacklist, SecureBlue kernel flags and some extras, locked kernel & kernel modules at runtime
  - **System Hardening:** SecureBlue sysctl options and some extras, NTS (Network Time Security), closed firewall, disabling unnecessary services, extensive systemctl hardening, USBGuard is implemented, PAM faillock is in use and locks after 3 wrong tries, DNSCrypt. See [docs/HARDENING.md](docs/HARDENING.md)
  - **No SUID:** no SUID binaries at all, SUIDs replaced by capabilities or removed altogether, run0 instead of sudo, noexec on ~/.cache and /boot, nosuid on all filesystems
  - **Development:** Rust, Python(uv), C, Zed Editor, Ghidra
  - **Apps:** Tor Browser, the ArtCraft Craft App Suite (WordCraft, DeckCraft, GridCraft, PdfCraft, VectorCraft), Orca Slicer, Kdenlive, mpv, OBS, Obsidian, Gnome Calculator, Fedora Media Writer, Monero Wallet, Slick (Slack client mod), Fluxer Canary. See [docs/APPS.md](docs/APPS.md)
  - **CLI/TUI:** Zsh with zsh-syntax-highlighting and theming, yazi, btop, htop, eza, fzf, opencode, bat, and common tools. See [docs/CLI.md](docs/CLI.md)
  
  The security part of this configuration is currently incomplete, as NixOS does not currently have stable MAC (Mandatory Access Control) support. Similar sandboxing is being done using jail.nix. Once AppArmor as well as apparmod.d will stabilize on NixOS, it will be implemented for maximum security.

## PublicVM, AnotherPublicVM, HomeLabVM & VPS
  - **Containers**: Rootless podman. See [docs/CONTAINERS.md](docs/CONTAINERS.md)
  - **Users**: privileged user for management, unprivileged deploy/guest user for deployment
  - **Bootloader:** systemd-boot
  - **File System:** ext4
  - **Kernel:** Linux Mainline
  - **No SUID:** no SUID binaries at all, SUIDs replaced by capabilities or removed altogether, run0 instead of sudo, noexec on ~/.cache and /boot, nosuid on all filesystems
  - **Impermanence:** Only select directories and files are kept on each reboot, / is a tmpfs, and the system remains clean.
  - **Kernel Hardening:** SecureBlue module blacklist, SecureBlue kernel flags and some extras, locked kernel & modules at runtime
  - **System Hardening:** SecureBlue sysctl options and some extras, NTS (Network Time Security), closed firewall, disabling unnecessary services, extensive systemctl hardening, DNSCrypt
  - **CLI/TUI:** Zsh with zsh-syntax-highlighting and theming, yazi, btop, htop, eza, fzf, bat, and common tools 

## Installation

Installation is done with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere). Every host has a disko layout in `modules/hosts/<host>/disko.nix`, and nixos-anywhere runs disko for you. This wipes the disk. `/` is a tmpfs and only `/persist` survives a reboot.

| Host | Disk | Login user | Secrets | SSH |
| --- | --- | --- | --- | --- |
| `framework16` | `/dev/nvme0n1` (LUKS) | `csd4ni3l` | `modules/hosts/framework16/secrets.yml` | no |
| `vps` | `/dev/vda` | `user` | `modules/hosts/vps/secrets/*.yml` | yes |
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

### Update Hosts

On the laptop, run the `rebuild` alias. On the VMs, run the `rebuild` command, which pulls the repo into `/persist/nix-config`, shows you the commits it's about to switch to, and asks before switching. Both end in `run0 nixos-rebuild switch`.

### Automated git updates

Scheduled Forgejo Actions under `.forgejo/workflows/` bump the version pins in this repo and open a PR:

- **update-flake** (every 3 days): `nix flake update`, then evals every host's toplevel before opening a PR
- **update-packages** (every 3 days): `nix-update` for `pkgs`
- **update-containers** (every 3 days): bumps the fully pinned `Image=` tags with skopeo;
- **podman-auto-update timer** on every server user: pulls `AutoUpdate=registry` images daily

Nothing gets applied on its own. You run `rebuild` when you're ready to take the update.

## Mirrors

[![Forgejo](https://img.shields.io/badge/Forgejo-git.csd4ni3l.hu-1e90ff)](https://git.csd4ni3l.hu/csd4ni3l/nixos-config)
[![GitHub](https://img.shields.io/badge/GitHub-github.com-181717)](https://github.com/csd4ni3l/nixos-config)
[![Codeberg](https://img.shields.io/badge/Codeberg-codeberg.org-2185D0)](https://codeberg.org/csd4ni3l/nixos-config)
