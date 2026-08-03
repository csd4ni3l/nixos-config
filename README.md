My hardened NixOS configuration. Uses CachyOS kernel, has lots of hardening options, uses modern Wayland, and includes lots of tools and apps.

- **WM:** niri
- **Shell:** Noctalia
- **Browser:** Firefox
- **Theme**: Catpuccin Mocha Compact
- **Gaming:** Steam, MangoHud, GameMode, Gamescope, Anime Game Launcher on Linux (AAGL)
- **Virtualization:** Podman + virt-manager (QEMU)
- **Bootloader:** Limine with Secure Boot
- **File System:** ext4 protected by LUKS
- **Kernel:** CachyOS-latest-zen4
- **Nixpak:** GUI apps are sandboxed and have least-privilege access to system resources and files where possible. (Exceptions: mpv, firefox. home-manager manages them.)
- **Impermanence:** Only select directories and files are kept on each reboot, / is a tmpfs, and the system remains clean.
- **Kernel Hardening:** SecureBlue module blacklist, SecureBlue kernel flags and some extras, locked kernel & kernel modules at runtime
- **System Hardening:** SecureBlue sysctl options and some extras, NTS (Network Time Security), closed firewall, disabling unneccessary services, extensive systemctl hardening, USBGuard implemented
- **No SUID:** no SUID binaries at all, SUIDs replaced by capabilities or removed altogether, run0 instead of sudo, noexec on ~/.cache and /boot, nosuid on all filesystems
- **Apps & Tools:** Rust, Python(uv), Hacking, OSINT, C debugging, Zed Editor, all the great shell tools, and lots of random stuff

The security part of this configuration is currently incomplete, as NixOS does not currently have stable MAC (Mandatory Access Control) support. Similar sandboxing is being done using nixpak. Once AppArmor as well as apparmod.d will stabilize on NixOS, it will be implemented for maximum security. Also, firefox and mpv are managed by home-manager to keep configs. Their package is not nullable, so i cannot nixpak them.

## Mirrors

[![Forgejo](https://img.shields.io/badge/Forgejo-git.csd4ni3l.hu-1e90ff)](https://git.csd4ni3l.hu/csd4ni3l/nixos-config)
[![GitHub](https://img.shields.io/badge/GitHub-github.com-181717)](https://github.com/csd4ni3l/nixos-config)
[![Codeberg](https://img.shields.io/badge/Codeberg-codeberg.org-2185D0)](https://codeberg.org/csd4ni3l/nixos-config)
