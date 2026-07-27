My hardened & very hardcoded/opinionated NixOS configuration. Uses CachyOS kernel, has lots of hardening options, uses modern Wayland, and includes lots of tools and apps.

- **WM:** niri
- **Shell:** Noctalia
- **Browser:** Firefox
- **Theme**: Catpuccin Mocha Compact
- **Gaming:** Steam, MangoHud, GameMode, Gamescope, Twintail Launcher
- **Virtualization:** Podman + virt-manager (QEMU)
- **Bootloader:** Limine with Secure Boot
- **File System:** ext4 protected by LUKS
- **Flatpak apps:** opinionated, declarative, and hardened with overrides
- **Hardening:** SecureBlue kernel flags and some extras, SecureBlue sysctl options and some extras, SecureBlue module blacklist, NTS (Network Time Security), closed firewall, protected kernel, disabling unneccessary services, extensive systemctl hardening, no SUID binaries, SUIDs replaced by capabilities or removed altogether, run0 instead of sudo, noexec on ~/.cache and /boot, nosuid on all filesystems, USBGuard implemented
- **Kernel:** CachyOS-latest-zen4
- **Apps & Tools:** Rust, Python(uv, pipx), Hacking, OSINT, C debugging, Zed Editor, all the great shell tools, and lots of random stuff

The security part of this configuration is currently incomplete, as NixOS does not currently have stable MAC (Mandatory Access Control) support. Once AppArmor as well as apparmod.d will stabilize on NixOS, it will be implemented for maximum security.
