## Desktop environment

| Piece | What it is |
| --- | --- |
| niri | Wayland compositor, scrollable, keyboard driven |
| Dank Material Shell (DMS) | desktop shell: bar, launcher, notifications, control center, lockscreen |
| Dank Greeter | the greetd login screen from the DMS family |
| Stylix | applies the Nord base16 scheme to everything that supports it |
| xwayland-satellite | lets X11 only apps run under Wayland |

Nord everywhere. Inter for sans, DejaVu Serif, JetBrainsMono Nerd Font for monospace, Noto Color Emoji, Bibata-Modern-Ice at size 24 for the cursor.

Stylix skips four apps, Firefox, Zed, MangoHud and Qt. Those are themed by hand because Stylix would overwrite the work. DMS themes itself.

Audio is pipewire with wireplumber, ALSA with 32 bit support for old games, and pulse for compatibility with older apps. 

mpris-proxy is on so headset buttons work, gnome-keyring keeps secrets. wl-mirror mirrors the screen in a new window. xdg-desktop-portal runs with both the GTK and GNOME backends, which is what lets the sandboxed apps open files.

## Applications

Sandboxed apps are covered in [SANDBOXING.md](SANDBOXING.md). The jailed apps see an empty home directory plus a few paths bound on purpose, and no network unless its defined.

| App | What it is | Sandboxed |
| --- | --- | --- |
| Firefox | the main browser | yes |
| Tor Browser | the anonymous one | yes |
| Slick | Slack client | yes |
| Fluxer | chat | yes |
| WordCraft, DeckCraft, GridCraft, PdfCraft, VectorCraft | documents, presentations, spreadsheets, PDFs, vector art, the ArtCraft suite | yes |
| mpv | video and audio player | yes |
| Kdenlive | video editor | yes |
| OBS Studio | recording | yes, with no network |
| Orca Slicer | 3D printing slicer | yes |
| Fedora Media Writer | writes ISO images to USB drives and SD cards | yes |
| GNOME Calculator | calculator | yes |
| Obsidian | notes, vault in `~/Documents/ObsidianVault` | yes |
| Monero GUI | wallet | yes |
| Nicotine+ | Soulseek client | yes |
| Zed | code editor | yes |
| Ghidra | reverse engineering | yes |
| opencode | coding agent | yes |
| Anime Game Launcher | launcher for the Honkai and Genshin games | yes |
| Prism Launcher | Minecraft | yes |
| ProtonPlus | installs Proton versions for Steam | yes |
| Steam | games | yes |
| GNOME Text Editor | plain text, and the default for source files | no |
| Nautilus | file manager | no |
| Loupe | image viewer | no |
| File Roller | archive manager | no |
| Pavucontrol | audio mixer | no |
| Mission Center | system monitor | no |
| Proton VPN, Onionshare | encryption and network privacy | no |
| virt-manager | QEMU virtual machines, rootless | no |
| proxmox-backup-client | backups, hourly timer | no |
| kitty, cava, oh-my-posh | terminal, audio visualiser, prompt | no |
| ffmpeg, grim, slurp | media and screenshots | no |

Mission Center is unsandboxed because it needs privileged/close access to system resources.

## File associations

| Type | Opens in |
| --- | --- |
| directories | Nautilus |
| plain text, Markdown, Python, Rust, JSON, XML | GNOME Text Editor |
| images | Loupe |
| SVG | VectorCraft |
| PDF | PdfCraft |
| video and audio | mpv |
| office documents | WordCraft, DeckCraft or GridCraft depending on format |
| archives | File Roller |
| web links and HTML | Firefox |

Source files open in GNOME Text Editor rather than Zed because Zed is sandboxed, and cannot be opened multiple times (would create multiple jails). It also can't see a file that isn't bound to it, so it can't open everything. Unlike the simple text editor, zed may run code, and has plugins and LSPs, which are an attack vector.

## Browser

Firefox does the browsing, configured from two places. Enterprise policies and a user.js.

The policies are locked, so Firefox can't override them:

- Telemetry, studies, accounts, screenshots, Pocket, recommendations, profile import, master password and desktop background are off.
- AI features are off and locked, including the chatbot, link previews, tab groups, translations and sidebar.
- Firefox's password manager is off since Bitwarden handles it, and so is autofill.
- Tracking protection is strict, HTTPS-only is forced, and the URL shortener allow list goes to uBlock Origin.
- On shutdown the cache, cookies, form data, history and sessions are wiped, except for origins on the cookie allowlist. That's where staying logged in matters: Slack, Proton, Discord, this domain.
- uBlock Origin, Bitwarden and the Nord theme are force-installed with updates off. Everything else is blocked.
- DNS over HTTPS is off and locked, since the VPN handles resolution.
- Downloads go to `~/Downloads`, one of three paths Firefox can write to.

The user.js is the full arkenfox set, with fingerprint resistance, letterboxing and English spoofing on, plus no URL bar suggestions, prefetching, DRM or machine learning. History stays on since the policy wipes it anyway.

Default search engine is `degoog`, self-hosted on homelabvm, aliased `@dg`. Normal and private windows both use it.

## Gaming

| Piece | What it does |
| --- | --- |
| Steam | sandboxed, see SANDBOXING.md |
| ProtonPlus | installs specific Proton versions, sandboxed, needs `~/.steam` and `~/.local/share/Steam` |
| gamescope | the nested compositor games run inside |
| gamemode | CPU governor and priority while a game runs |
| ntsync | kernel module for better sync with NT primitives |
| dmemcg-booster | Service for enabling and controlling dmem cgroup limits for boosting foreground games |
| amdgpu_top, MangoHud | monitoring and overlay |
| Anime Game Launcher | Launcher for the Genshin Impact game, from a third party flake, telemetry domains blocked at the network level |

MangoHud is hand-themed, so Stylix leaves it alone. Config is in `home/modules/desktop/cfg/mangohud/`.

## Virtualisation on the laptop

virt-manager talks to `qemu://session`, which is rootless. Your user isn't in the `libvirtd` group, because that group hands out rootful QEMU. Containers use rootless podman, with pasta for networking and docker-compose for the easy syntax.

Every VM needs a built in virtio SCSI controller and a built in virtio network card. Kernel modules can't load after boot, so a module would arrive too late for root and networking. See the README and [HARDENING.md](HARDENING.md).

## Backups

The laptop runs an hourly proxmox-backup-client timer over the persisted home directory, leaving out caches, Steam, toolchains, images and virtual disks. The servers have nothing like it. See [CONTAINERS.md](CONTAINERS.md).
