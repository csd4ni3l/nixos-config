## Shell

zsh everywhere, on at system level and again through Home Manager. Home Manager keeps the config in `~/.config/zsh`, so it's `~/.config/zsh/.zshrc` and friends rather than dotfiles loose in your home.

Completion comes from the Home Manager zsh module. `zsh-autosuggestions` shows old commands as grey text while you type. `zsh-syntax-highlighting` uses a Nord scheme written by hand:

| Token | Colour |
| --- | --- |
| comments | muted blue grey |
| commands, aliases, functions, builtins, reserved words | yellow |
| quoted arguments | green |
| unknown tokens and separators | red |
| paths, globbing, assignment, redirection, default | near white |
| back quoted arguments, history expansion | purple |

`Ctrl+Right` and `Ctrl+Left` move by word. The prompt is oh-my-posh on `nordtron`.

History holds 200 entries and is shared across sessions you have open at once. Duplicates get dropped, as do commands starting with a space. The zoxide database persists; the history file doesn't, so history dies on reboot.

`~/.bashrc`, `~/.profile`, `~/.bash_profile`, `~/.bash_login`, `~/.bash_logout` and the zsh login and logout files all get created empty. Land in bash or sh for any reason and you start with nothing rather than inheriting somebody else's config.

The terminal is kitty with 10000 lines of scrollback and no audio bell. Closing a window never asks to confirm.

## Aliases

| Alias | Runs | Note |
| --- | --- | --- |
| `cat` | `bat --style=plain --pager=never` | no file decoration, no paging |
| `cd` | `z` | zoxide, so `cd` is a jump, not a change |
| `ls` | `eza` | |
| `ll` | `eza -la` | |
| `top` | `btop` | |
| `lg` | `lazygit` | |
| `yz` | `yazi` | |
| `gs` | `git status` | |
| `mount` | `run0 mount` | asks for the root password |
| `umount` | `run0 umount` | asks for the root password |
| `ssh` | `kitten ssh` | laptop only |
| `rebuild` | `run0 nixos-rebuild switch --flake ~/Projects/nixos-config --no-reexec --accept-flake-config` | laptop only |

These only apply at a prompt. A script that shells out gets the real commands, which is why `cd` in a script is still an actual directory change.

Some of these bite. `cat` is `bat` with paging off so piping works, so reading something long means running `bat --pager=always` yourself. `ls` is eza, which doesn't take every GNU ls option. `mount` and `umount` prompt because they go through `run0`, though desktop mounting uses udisks2 and never asks.

`ssh` is `kitten ssh`, there to ship kitty's terminfo over the connection. Run that from another terminal or a script and the `xterm-kitty` entry may not be there, in which case plain `ssh` is the fallback.

## Everyday tools

| Category | Tools |
| --- | --- |
| Files | eza, fd, bat, fzf, yazi with hidden files shown, tree, ncdu |
| Search | ripgrep, fzf, fd, tldr |
| Git | git, lazygit |
| Navigation | zoxide with zsh integration |
| Monitors | btop, htop, cava |
| Info | fastfetch, file |
| Data | jq, sqlite, dnsutils |
| Transfer | wget, unzip |
| Secrets | sops, age |
| Fun | nyancat, jrnl |

On the laptop `EZA_COLORS` matches the Nord palette so file type colours fit. Stylix handles kitty, the shell and everything else it knows about, skipping the same four as everywhere else: Firefox, Zed, MangoHud and Qt.

## Development

| Category | Tools |
| --- | --- |
| Languages | Go, Rust through rustup, Python through uv, C toolchain (gcc, gdb, make) |
| Accelerators | ccache, mold as the linker |
| JS | bun |
| Security | gitleaks for secret scanning, gosec for Go static analysis |
| Web | sqlc |
| Reverse engineering | Ghidra, sandboxed |
| Sites | zola, my preferred static site generator |
| Media | ffmpeg, xorriso for discs and ISOs |
| Language servers | pyright, nixd, nil |
| Formatters | alejandra for Nix, tombi for TOML |
| Editors | Zed and opencode, both sandboxed |
| Secrets | sops, age |

Zed has extensions for HTML, log, Nix, TOML, Dockerfile, SQL, Make, Go, Hackatime and Nord. Panels dock left, agent sidebar on the right.

jrnl handles the journal with nano as the editor and encryption on. No template, wraps at 79 characters, and the journal lives in a directory that survives reboot.

## Privilege

There's no `sudo`. You use `run0`, and it always asks for the root password.

```
run0 nixos-rebuild switch --flake ~/Projects/nixos-config --no-reexec --accept-flake-config
run0 mount /dev/sda2 /mnt
run0 su deploy
run0 systemctl restart podman
```

`sudo` is still there as a symlink to `run0` so programs looking for it don't fall over, but it doesn't understand sudo options. Your login user is in `wheel`, the only group that can escalate.

To become a container user, `run0 su deploy` or `run0 su guest`. Plain `su deploy` fails since `su` lost its SUID bit.

## Nix

`nix-command` and `flakes` are on, so `nix` does what you expect without extra flags.

Garbage collection runs daily and drops anything older than two days. Hardlink optimisation is on. There's no trash, so two days means gone.

One third party binary cache, laptop only, the Anime Game Launcher's. Servers pull from cache.nixos.org and nothing else. Substituters are trusted by key rather than left open.

Installs go through nixos-anywhere, which runs disko and wipes the disk. See the README.

The store sits on `/persist`, so it survives reboots and garbage collection actually reaches it. Anything you can't afford to lose stays out.

## Rebuilding

The laptop uses the `rebuild` alias from the table above, building whatever's in `~/Projects/nixos-config`.

The VMs have a `rebuild` command instead, from `home/modules/server/rebuild.nix`. It keeps a clone at `/persist/nix-config` that survives reboots, which is what lets it diff against history. It:

- clones the repo if missing, fixing ownership if it's still root owned
- runs `git pull --ff-only`
- shows the commits and diffstat between old and new
- if anything moved, or the tree is dirty, asks `switch to <sha>? [y/N]` and waits
- refuses to switch when stdout isn't a terminal, so a scripted run can't pick up changes nobody looked at
- ends with `run0 nixos-rebuild switch --flake /persist/nix-config#<host> --no-reexec --accept-flake-config`

`rebuild --no-pull` builds the clone as-is. `rebuild --help` prints the usage.

## Host differences

The VMs pull in only the shared CLI modules, so they get zsh, the common aliases, the file and search tools, btop, lazygit, git, podman, docker-compose, passt, sops and age.

No kitty, oh-my-posh, cava, jrnl config, dev toolchain or Home Manager git config. That last one has a side effect. Commits on a VM have no name, email or default branch set, and `git pull` there makes merge commits instead of rebasing. `rebuild` mostly sidesteps that with `--ff-only`.

openssl, the Nord `EZA_COLORS` and the zsh history defaults are laptop only as well.

## What the shell runs in

Some system-wide settings change what works in a terminal:

- No core dumps. `core_pattern` pipes into `/bin/false`, so a segfault leaves nothing for gdb.
- Attaching to processes is restricted. `yama.ptrace_scope=1` only lets you trace your own children, so poking at something another process started, a Steam game or a systemd service, needs `run0`.
- Profiling needs privileges. `perf_event_paranoid=3` limits `perf` and the eBPF profilers to roughly debugger capabilities.
- `~/.cache` is a `noexec` 4 GB tmpfs. A tool that downloads a binary into the cache and runs it fails, and a big build can fill it.
- `io_uring` is off system wide, so anything built on `liburing` dies with `EPERM`.
- Kernel messages never reach the console. `loglevel=0` and `quiet` mean an empty boot log, so `journalctl -kf` from another tty is how you watch the kernel.
- No kernel modules load after boot. Everything needed is preloaded, so new hardware means a rebuild.
- opencode and Zed are sandboxed, and so is anything they spawn a shell for. See [SANDBOXING.md](SANDBOXING.md).
- Three bad `run0` prompts lock privileged operations out for thirty minutes on the laptop, same counter as login. See [HARDENING.md](HARDENING.md).
