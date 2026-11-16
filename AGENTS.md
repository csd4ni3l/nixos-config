# Agent Conventions

## Core Rule

Always take the smallest step that actually solves the task. Do not refactor, reformat,
rename, or touch unrelated files unless the change requires it.

Read the relevant docs and source before acting. If a build flag, module option, host
layout, or convention is not obvious from this file, read `docs/` or the module itself
instead of guessing.

Do not switch, deploy, or reboot a host unless the user explicitly asks. Config
changes should be verified with an evaluation or build.

## Repository

A hardened, dendritic NixOS configuration for one laptop and several VMs.

- `framework16` — the laptop: niri, Dank Material Shell, LUKS + Limine + Secure Boot,
  Zen kernel, impermanence, jail.nix sandboxing.
- `vps`, `homelabvm`, `publicvm`, `anotherpublicvm` — servers/VMs: systemd-boot,
  mainline kernel, rootless podman containers, impermanence.

Everything is modular through flake-parts and `import-tree`. CI is Forgejo Actions:
scheduled workflows bump `flake.lock`, packages, and pinned container images, then
open a PR. Routine version bumps are handled there; do not duplicate them unless asked.

## Directory Structure

```
.
├── modules/                     # Auto-imported by import-tree
│   ├── features/                # Reusable NixOS modules
│   │   ├── services/            #   bluetooth, networking, ssh, tailscale, ...
│   │   ├── system/              #   boot, core, desktop, hardening
│   │   ├── jail.nix/            #   jail.nix sandbox wrappers
│   │   │   ├── lib/_jail.nix    #     shared combinators + mkSandboxed
│   │   │   └── programs/        #     one module per sandboxed app
│   │   └── _template.nix        #   ignored by import-tree; copy this shape
│   ├── hosts/                   # Per-host configuration
│   │   ├── {host}/default.nix   #   flake.nixosConfigurations entry
│   │   ├── {host}/configuration.nix # imports + host settings
│   │   ├── {host}/boot.nix      #   bootloader / kernel
│   │   ├── {host}/disko.nix     #   disk layout
│   │   ├── {host}/sops.nix      #   sops defaults
│   │   └── {host}/secrets*      #   sops-encrypted secrets
│   ├── options.nix              # Shared `nixcfgs.*` options
│   └── packages.nix             # perSystem packages built from `pkgs/`
├── home/                        # Home Manager config, imported per host
│   ├── modules/common/          #   shell, sops, environment lockdown
│   ├── modules/desktop/         #   laptop desktop, apps, theme, backups
│   ├── modules/server/          #   containers, services, rebuild command
│   └── {host}.nix               #   per-host Home Manager entry point
├── pkgs/                        # Custom packages (craft suite, dmemcg-booster, ...)
├── scripts/                     # Forgejo automation helpers
├── docs/                        # User-facing documentation
├── .forgejo/workflows/          # Scheduled update PRs
├── flake.nix                    # Inputs + `import-tree ./modules`
└── .sops.yaml                   # sops creation rules
```

## How Modules Fit Together

- `flake.nix` calls `import-tree ./modules`, so every `.nix` file under `modules/`
  is imported automatically. Paths containing a `_`-prefixed file or directory are
  ignored, which is why `_template.nix` and `lib/_jail.nix` are not registered.
- A new module follows the dendritic shape:

  ```nix
  {self, ...}: {
    flake.nixosModules.<name> = {pkgs, lib, config, ...}: {
      # ...
    };
  }
  ```

  Adding the file registers the flake output, but it does nothing until the output is
  added to a host's `imports` in `modules/hosts/{host}/configuration.nix`.
- Home Manager modules are not auto-imported. Add them to `home/{host}.nix`, or to a
  shared `home/modules/*/default.nix` that `home/{host}.nix` imports.
- Use `self.nixosModules.<name>` / `self.homeModules.<name>` for shared modules.
  Use relative paths only for files belonging to the same host or feature.
- Shared options belong in `modules/options.nix` under `nixcfgs.*`, defined with
  `lib.mkOption` or `lib.mkEnableOption`. Host-specific values go in the host's
  `configuration.nix`, not in a shared feature.
- Packages under `pkgs/` are exposed in `modules/packages.nix` via
  `pkgs.callPackage ../pkgs/<name> {}`.
- Sandboxed apps live in `modules/features/jail.nix/programs/`. They import
  `../../lib/_jail.nix`, wrap the package with `jail.mkSandboxed`, and are added to
  the host's imports. Home-relative paths the jail needs are listed in
  `nixcfgs.jail_dirs`.

## Code Style

- **Formatter**: Alejandra. Run `alejandra <file>` after edits, or
  `nix run nixpkgs#alejandra -- <file>` if it is not on `PATH`. There is no flake
  `formatter` output, so `nix fmt` is not the way to format this repo. Never format
  unmodified files.
- **Indentation**: 2 spaces, no tabs.
- **Line endings**: LF, final newline, trimmed trailing whitespace.
- **Nix conventions**:
  - Top-level files take flake inputs, usually `{self, ...}:`.
  - Module functions take `{pkgs, lib, config, inputs, ...}` as needed.
  - Prefer `lib.mkOption` / `lib.mkEnableOption` for new options.
  - Comments explain why, not what. Use `# NOTE:` for security trade-offs and
    non-obvious decisions, matching the existing modules.
  - Keep host-specific quirks in the host directory; keep shared features reusable.

## Commit Messages

Use Conventional Commits: `type(scope): description`.

- **Types**: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `perf`, `WIP`.
- **Scope**: path-based, reflecting the changed area:
  - `hosts/{host}` for host-specific config: `hosts/framework16`, `hosts/vps`
  - `hosts/{host}/{service}` for one service on one host
  - `home/{area}` for Home Manager modules: `home/desktop`, `home/server`
  - `{component}` for shared NixOS modules: `hardening`, `jail`, `services`, `system`
  - `containers` for container modules
  - `pkgs` or `pkgs/{name}` for custom packages
  - `flake` for `flake.lock` and `flake.nix`
  - `docs` for documentation only
- Description is lowercase, imperative, and has no trailing period.
- Keep commits focused. Do not mix formatting or unrelated cleanup into a functional
  change.

### Flake Lock Bumps

When updating an input manually (e.g. `nix flake update <input>`), summarize what
actually changed, not just the hashes:

1. Get the old and new revisions from the `nix flake update` output or the
   `flake.lock` diff.
2. Fetch the upstream changelog between them (GitHub compare API or a local clone in
   `/tmp`): `curl -s https://api.github.com/repos/<owner>/<repo>/compare/<old>...<new>`.
3. In the commit body, note the short hash range and a brief bullet list of meaningful
   changes.

Example:

```
chore(flake): update nixpkgs input

Update nixpkgs from abc1234 to def5678:
- bump linux kernel to 6.x
- fix evaluation of foo module
```

## Secrets

- Managed with **sops-nix** and post-quantum age keys. Creation rules are in
  `.sops.yaml`.
- Secret files:
  - `modules/hosts/framework16/secrets.yml` — laptop secrets.
  - `modules/hosts/{vps,homelabvm,publicvm,anotherpublicvm}/secrets/*.yml` —
    per-user files such as `user.yml`, `deploy.yml`, and `guest.yml`.
- Both the system config and Home Manager use sops; Home Manager sets
  `sops.defaultSopsFile` in `home/{host}.nix`.
- **Never** read, decrypt, print, or copy secrets into context, commits, or temporary
  files. If a change needs a secret value, ask the user to do it.
- After adding a recipient or changing `.sops.yaml`, the user re-encrypts with
  `sops updatekeys <file>`.

## Building and Evaluating

- Format a file: `alejandra <file>`.
- Build a host without switching:
  `nixos-rebuild build --flake .#framework16`
- Evaluate the full system derivation (what CI uses):
  `nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`
- Inspect a NixOS option:
  `nix eval .#nixosConfigurations.<host>.config.<path> --json`
- Inspect a Home Manager option (managed by NixOS):
  `nix eval .#nixosConfigurations.<host>.config.home-manager.users.<user>.<path> --json`
- Build a generated file:
  `nix build <path>.source --no-link --print-out-paths`

Do not deploy with `nixos-rebuild switch` or the host `rebuild` command unless the
user asks. The laptop deploys with its `rebuild` alias; the VMs use the `rebuild`
command from `home/modules/server/rebuild.nix`, which pulls, shows the diff, and asks
before switching.

## Documentation

Read the relevant doc before changing that subsystem:

| Doc | Covers |
| --- | --- |
| `README.md` | Hosts, installation, age keys, updating, mirrors |
| `docs/APPS.md` | Apps on framework16 and containers on the VMs |
| `docs/CLI.md` | Shell, aliases, terminal, dev toolchain, privileges, Nix setup, rebuilding |
| `docs/CONTAINERS.md` | Containers, users, port map, network wiring, trade-offs |
| `docs/HARDENING.md` | Per-host hardening and its limits |
| `docs/SANDBOXING.md` | How jail.nix wraps apps and what each sandbox can touch |

Do not add new documentation unless asked. Update stale docs as part of the change
that made them stale. Runbooks and notes that only describe machine state do not
belong in this repository.

## Tests

There is no test suite. Ad-hoc tests belong in `/tmp`, not in this repository.
Unless explicitly asked, do not add new test harnesses or durable test files. For
config changes, verify with evaluation or `nixos-rebuild build` instead.
