# Apps

What's installed on the laptop and what's running on the VMs, what each one is for, and whether it's sandboxed.

## Desktop environment

| Piece | What it is |
| --- | --- |
| niri | Wayland compositor, scrollable, keyboard driven |
| Noctalia | desktop shell: bar, launcher, notifications, workspace indicator |
| Noctalia Greeter | the login and lock screen |
| Stylix | applies the Nord base16 scheme to everything that supports it |
| xwayland-satellite | lets X11 only apps run under Wayland |

Nord everywhere. Inter for sans, DejaVu Serif, JetBrainsMono Nerd Font for monospace, Noto Color Emoji, Bibata-Modern-Ice at size 24 for the cursor.

Stylix skips five apps, Firefox, Zed, MangoHud, Noctalia and Qt. Those are themed by hand because Stylix would overwrite the work. Noctalia additionally picks DejaVu Sans for the bar and shell.

Audio is pipewire with wireplumber, ALSA with 32 bit support for old games, and pulse for compatibility. mpris-proxy is on so headset buttons work, gnome-keyring keeps secrets. Screenshots are slurp and grim, wl-mirror mirrors the screen. xdg-desktop-portal runs with both the GTK and GNOME backends, which is what lets the sandboxed apps open files.

## Applications

Sandboxed apps are covered in [SANDBOXING.md](SANDBOXING.md). One sees an empty home directory plus a few paths bound on purpose, and no network unless the module asks for it.

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

Mission Center is the one unsandboxed app, which needs to read `/proc` for every process and pull real system numbers, and a sandbox makes that kinda hard to do.

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

Source files open in GNOME Text Editor rather than Zed because Zed is sandboxed. It can't see a file that isn't bound to it, so it can't open whatever you just double clicked.

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

Two of those are worth a second look. Automatic updates being off means Firefox sits on whatever version nixpkgs gave you until you rebuild. And `about:config` being reachable means the arkenfox prefs below are editable at runtime instead of fixed by policy.

The user.js is the full arkenfox set, with fingerprint resistance, letterboxing and English spoofing on, plus no URL bar suggestions, prefetching, DRM or machine learning. History stays on since the policy wipes it anyway.

Default search engine is `degoog`, self-hosted on homelabvm, aliased `@dg`. Normal and private windows both use it.

## Gaming

| Piece | What it does |
| --- | --- |
| Steam | sandboxed, see SANDBOXING.md |
| ProtonPlus | installs specific Proton versions, sandboxed, needs `~/.steam` and `~/.local/share/Steam` |
| gamescope | the nested compositor games run inside |
| gamemode | CPU governor and priority while a game runs |
| ntsync | kernel module for frame pacing and input latency |
| dxvk, wine, vulkan-tools | translation layers and debugging tools |
| dmemcg-booster | local package holding the GPU memory clock up under load so it doesn't drop back down |
| amdgpu_top, MangoHud | monitoring and overlay |
| Anime Game Launcher | HoYo games, from a third party flake, telemetry domains blocked at the network level |

MangoHud is hand-themed, so Stylix leaves it alone. Config is in `home/modules/desktop/cfg/mangohud/`.

## Virtualisation on the laptop

virt-manager talks to `qemu://session`, which is rootless. Your user isn't in the `libvirtd` group, because that group hands out rootful QEMU. Containers use rootless podman, with pasta for networking and docker-compose for the easy syntax.

Every VM needs a built in virtio SCSI controller and a built in virtio network card. Kernel modules can't load after boot, so a module would arrive too late for root and networking. See the README and [HARDENING.md](HARDENING.md).

## Backups

The laptop runs an hourly proxmox-backup-client timer over the persisted home directory, leaving out caches, Steam, toolchains, images and virtual disks. The servers have nothing like it. See [CONTAINERS.md](CONTAINERS.md).

## Self-hosted services

Everything on the VPS and the three VMs runs as rootless podman quadlets. Two container users: `deploy` for normal services, `guest` for anything not fully trusted. Web services bind to `127.0.0.1` on their own port and reach the internet through Pangolin and Traefik on the VPS, or Nginx Proxy Manager on homelabvm.

| Host | What it runs |
| --- | --- |
| vps | the Pangolin control plane, the Gerbil tunnel, Traefik, CrowdSec, MariaDB |
| homelabvm | Nginx Proxy Manager, Vaultwarden, Navidrome, FreshRSS, Karakeep, OpenWebUI, the MCP gateway, open-terminal, ntfy, Vikunja, IT Tools, Aonsoku, degoog |
| publicvm | Forgejo, the Pelican panel, the site, PrivateBin and the Pangolin Site connector as `deploy`; the Actions runner and Wings as `guest` |
| anotherpublicvm | the Pangolin Site connector, the Actions runner and Wings, all as `guest` |

[CONTAINERS.md](CONTAINERS.md) has the port map, how the quadlets are wired, and what each container gives up.
