# Sandboxing

Most GUI apps on the laptop, plus a couple of CLI tools, run inside a jail.nix sandbox.

## The model

Every app is wrapped in bubblewrap at build time. It lands in a fresh mount namespace where almost nothing exists. Your home directory is an empty tmpfs, and paths get bind-mounted back in one at a time, read only or read write. Every namespace is unshared, including the network one unless the app asks otherwise. The environment gets cleared and rebuilt.

Anything not bound simply isn't there, and an app hitting a missing path gets no error at all.

## What every jail gets

From the jail.nix base plus the shared `common-access` and `gui-base` combinators.

| Piece | What is granted |
| --- | --- |
| Namespaces | user, ipc, pid, uts, cgroup and net all unshared |
| `/proc` | synthetic, built by the kernel for the new PID namespace |
| `/dev` | minimal set from `--dev /dev` |
| `/tmp` | tmpfs, gone when the app exits |
| `$HOME` | empty tmpfs, then the app's own binds |
| `/nix/store` | read only |
| `/run/current-system/sw` | read only, the whole system profile |
| `/etc` | `os-release`, `profiles`, `static/profiles`, plus fake `passwd` and `group` |
| `/lib64` | read only, so nix-ld can start foreign binaries |
| `PATH` | forwarded as is |
| Locale | `LANG` and `LOCALE_ARCHIVE` |
| User info | `SHELL`, `USER`, `LOGNAME` when set |
| Wayland | compositor socket, pipewire and pulse sockets |
| GPU | `/dev/dri`, `/sys/dev/char`, `/run/opengl-driver` |
| Fonts and cursor | `/etc/fonts`, `~/.config/fontconfig`, `~/.config/dconf`, `XCURSOR_*` |
| GTK and Qt config | `~/.config/gtk-2.0`, `gtk-3.0`, `gtk-4.0`, read only |
| Cache | private tmpfs at `~/.cache` |
| Session | `$XDG_RUNTIME_DIR`, plus its `dconf` and `doc` subdirectories |
| Appearance | `COLOR_SCHEME=prefer-dark`, `ELECTRON_OZONE_PLATFORM_HINT=auto`, Bibata-Modern-Ice at size 24 |
| Child processes | `--die-with-parent`, `--new-session` |

Since `$HOME` is empty, an app only reads and writes what someone bound in. Everything else it writes goes to a tmpfs and disappears on exit. Settings that reset themselves and saves that vanish are both this, not corruption.

Caches are per jail. Nothing is shared between two apps and nothing carries over. The price is that font, Mesa shader and GStreamer caches rebuild every launch, so Firefox, Slick and Zed each bind one host subdirectory to keep theirs.

The `/etc/passwd` in a jail is generated. Two lines, `root` and your own user, so the account list doesn't leak. `/run/current-system/sw` is a different story. It's bound whole, which means a jailed app can run anything in your system profile, `run0` included.

## D-Bus

Traffic goes through `xdg-dbus-proxy`, which the wrapper starts on the host before mounting its socket into the jail. Names are filtered, and only these pass:

- talk to `org.freedesktop.DBus`, `org.gtk.vfs`, `org.gtk.vfs.*`, `ca.desrt.dconf`, `org.freedesktop.portal.*`, `org.a11y.Bus`
- talk to `org.freedesktop.Notifications`
- own its own name

`org.freedesktop.portal.*` is what makes file choosers, printing and dialogs work. It's also the widest gap in the policy, because the glob pulls the Secret portal in with it.

opencode gets nothing here. It uses `common-access` instead of `gui-base`, so there's no proxy and no session bus.

## Network

Two states, and the module names make them easy to mix up.

With `network`, the net namespace is shared with the host. The jail also picks up `/etc/hosts`, `/etc/nsswitch.conf`, `/etc/resolv.conf`, `/etc/ssl`, `/etc/localtime`, `/run/systemd/resolve` and its own hostname. DNS and TLS work. Browsers, downloaders and updaters need this.

Without it, the net namespace is unshared and the app gets loopback and nothing else. No sockets out, no DNS, no CA bundle. That's deliberate for OBS and Kdenlive, and it's a real namespace rather than a suggestion.

Either way there's no egress filtering. An app with `network` reaches the router, the rest of your LAN, and everything you can reach. Tor Browser too.

## What each app gets

| App | Network | Read write paths | Notes |
| --- | --- | --- | --- |
| Firefox | yes | `~/Downloads`, `~/.config/mozilla`, `~/.cache/mozilla` | full `/dev` on framework16, or a FIDO token |
| Tor Browser | yes | `~/.config/tor-browser` as `~/.tor project` | nothing else from home |
| Slick | yes | `~/.config/slick`, `~/.cache/slick`, `~/Downloads` | only app with keyring access |
| Fluxer | yes | `~/.config/fluxercanary`, `~/Downloads` | |
| WordCraft | no | `~/Documents`, `~/Downloads`, own config and share | documents |
| DeckCraft | no | `~/Documents`, `~/Downloads`, own config and share | presentations, audio via pulse |
| GridCraft | no | `~/Documents`, `~/Downloads`, own config and share | spreadsheets |
| PdfCraft | no | `~/Documents`, `~/Downloads`, own config and share | PDFs |
| VectorCraft | no | `~/Pictures`, `~/Documents`, `~/Downloads`, own config and share | vector art |
| Orca Slicer | yes | `~/Projects/3D`, `~/.config/OrcaSlicer` | network is for the printer |
| Ghidra | no | `~/Projects/Programming` | X11, patched to stay foreground |
| Zed | yes | `~/Projects`, `~/Documents`, `~/Downloads`, Go, Cargo, rustup, uv, ccache trees, Zed config, zsh config, WakaTime | also reads `~/.ssh`, runs `--foreground` |
| Anime Game Launcher | yes | `~/.local/share/anime-game-launcher` | `/dev/ntsync`, telemetry blocked |
| Prism Launcher | yes | `~/.local/share/PrismLauncher` | X11 for Minecraft |
| ProtonPlus | yes | `~/.local/share/Steam`, `~/.steam` | |
| Steam | yes | `~/.local/share/Steam`, `~/.steam`, `~/Downloads`, four shader cache dirs | see below |
| Kdenlive | no | `~/Videos` | |
| mpv | yes | nothing writable, reads `~/Music`, `~/Videos`, `~/Downloads`, `/run/media` | |
| Nicotine+ | yes | `~/Music` | |
| Supersonic | yes | `~/.config/supersonic`, `~/Music` | music streaming, offline downloads in Music |
| OBS | no | `~/Videos/OBS`, `~/.config/obs-studio` | local only, no streaming |
| Obsidian | no | `~/Documents/ObsidianVault` | `try-rw-bind`, missing vault isn't an error |
| opencode | yes | its own config, share, state, plus `$PWD` | `mount-cwd` combinator |
| Fedora Media Writer | no | nothing writable, reads `~/Downloads` | full `/dev`, writes images to drives |
| GNOME Calculator | no | nothing | settings live in dconf |
| Monero GUI | yes | `~/.bitmonero`, `~/.p2pool`, `~/Documents/Monero` | |

gamescope, gamemode, the compositor, the portal and anything run from a shell are not in any of this.

## Steam

Steam keeps its own NixOS bubblewrap FHS wrapper, unmodified, running nested inside the jail. bwrap binds are recursive, so the inner wrapper mounts the jail's view of every top level directory, not the host's.

Binding the whole root read only was tried and fails, because NixOS fills `/bin`, `/lib64` and `/etc` with symlinks and bwrap won't mount onto one. The jail stays on the empty root like everything else, which happens to be what makes the nested wrapper safe: it can only mount what the jail already put there.

On top of the standard set, Steam gets its own directories, `~/Downloads`, `/run/media` and the shader caches, without which every launch rebuilds shaders. It also needs input devices for Steam Input, the sync device for Proton, sound, and the hidraw nodes for rumble and LEDs. `/sys` is bound whole because the GPU combinator's partial binds miss what Steam needs.

A few things about Steam are worth knowing:

- No system bus proxy, so the Big Picture battery indicator doesn't work.
- Games that save outside the Steam directory lose those saves on exit unless you add an `rw-bind`.
- Crash dumps go to `/tmp/dumps` in the jail tmpfs and get discarded.

## Apps with no config bound

The empty `$HOME` catches anything whose config directory never got bound.

| App | Directory missing | What resets |
| --- | --- | --- |
| mpv | `~/.config/mpv` | no `mpv.conf`, no per file options, no playlist history |
| Kdenlive | `~/.config/kdenlive` | project layout, render presets, recent files |
| Nicotine+ | `~/.config/nicotine-plus`, `~/.local/share/nicotine-plus` | connections, shares, downloads list |
| Obsidian | `~/.config/obsidian` | appearance and hotkeys, vault is fine |
| Ghidra | user preferences | analysis options |

The directory creation service makes these directories exist. Existing isn't the same as bound, so the fix is one `rw-bind` in the app's module.

## The Downloads rule

Firefox writes to three paths, its profile, its cache and `~/Downloads`. It can't see `~/Documents`, `~/Projects`, `~/Music`, `~/Videos`, `~/.ssh` or your keyring.

Copy files into `~/Downloads` first, then use the file picker or drag them in from Nautilus. Both resolve to the same bound path. Saves from any page land in `~/Downloads` because enterprise policy pins `DefaultDownloadDirectory` there.

The file picker shows the jail's filesystem, which is the empty tmpfs plus three binds, so anything else isn't listed at all. You can't save into a project directory. And whatever's sitting in Downloads is gone after a reboot, since `~/Downloads` isn't in the impermanence lists.

The Craft apps are the opposite. They read and write all of `~/Documents` and `~/Downloads`, so documents open and save where they actually live.

## Adding a sandboxed app

1. Create `modules/features/jail.nix/programs/<category>/<name>.nix`. `system/gnome-calculator.nix` is the smallest one to copy.
2. Import `_jail.nix` and call `jail.mkSandboxed <package> "<binary>" [ ...permissions ]`. The second argument is the binary name, which isn't always the package name: `monero-wallet-gui`, `ghidra`, `zeditor`, `nicotine`, `mediawriter`, `obs`.
3. `default` for GUI, `common-access` for terminal. Add `network` only if it needs the internet.
4. `rw-bind` for writes, `ro-bind` for reads, `try-` variants when the path might not exist.
5. `own` in the app's `dbus` call for its own name. Shared talk names go in the combinators.
6. Add every new path to the directory creation service. The source must exist before bubblewrap starts, which is why that's a user unit.
7. Import the module in the framework16 host configuration.

The wrapper is at `/run/current-system/sw/bin/<name>`. It's a bash script and the long bwrap line near the end has every bind.

## Where the model ends

The jail shares your uid. It stops an app reading your files without asking. It doesn't stop an app asking. `org.freedesktop.portal.*` is reachable and `run0` is in the profile, so a jailed app can put up a file chooser, a secret request, or a root prompt. Approve one and that app has your privileges. The Secret portal also means it can name items in your keyring.

No seccomp filtering. jail.nix has an `add-seccomp` combinator and this config doesn't use it, so any syscall the kernel allows is available. Namespaces and mount isolation are the whole boundary.

X11 isn't isolated. Ghidra, Prism Launcher and Steam use `unsafe-x11`, and an X11 client can reach any other window in the session and the display itself through Xwayland. Treat those three as trusted.

`--dev-bind /dev /dev` is a full device grant. Firefox has it because `nixcfgs.firefox_full_dev_access = true`, Fedora Media Writer has it unconditionally since it writes raw images. That covers cameras and microphones. Setting the option to `false` limits Firefox to a FIDO token.

`try-ro-bind` and `try-rw-bind` fail silently, so a typo gives you an app with no access and no error.

`--die-with-parent` is on. An app that daemonises loses its sandbox when the parent exits. Ghidra backgrounds its JVM by default and was patched to `launch.sh fg`; Zed got `--foreground`.

Zed has all of `~/Projects` and Ghidra all of `~/Projects/Programming`, both writable. A bad repo or binary under those trees is inside the boundary.

This is an app-level boundary. A compromised app that finds a kernel or D-Bus bug isn't stopped by it. AppArmor or SELinux would help and neither is on NixOS yet.

Only framework16 is sandboxed. The VMs are headless.

zsh doesn't work inside the opencode jail. Home Manager puts the zsh config in `~/.config/zsh`, which isn't bound there, so zsh falls back to `/bin/sh`, which is bash. Zed binds that directory, which is why its terminal is fine.