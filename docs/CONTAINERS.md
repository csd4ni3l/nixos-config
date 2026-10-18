# Containers

Everything running as a container on the VPS and the three VMs: what it is, who runs it, what port it sits on.

## How it works

Every container is a rootless podman quadlet. Home Manager writes each one as a plain text unit into `~/.config/containers/systemd/<name>.container`, and podman turns that directory into systemd units at start. A container is just an ordinary user service under `default.target`. No `podman run` anywhere, no compose file.

Networking goes through pasta as the rootless default. A container that doesn't declare `Network=` gets its own network namespace, outbound access and nothing coming in.

Ports are published one at a time with `PublishPort=127.0.0.1:<host>:<container>`. Everything web facing binds to loopback and gets reached through Nginx Proxy Manager or Traefik, never directly.

Data lives in `~/containers/<service>/` on the `/persist` filesystem. Volume mounts carry the `:Z` SELinux relabel, which does nothing here but keeps the syntax portable.

Ownership uses `UserNS=keep-id` where an image needs to write as a particular uid, so files the container writes are files you can read.

Secrets are declared with sops and rendered into `~/.config/sops-nix/secrets/rendered/`. They go in as `Environment=`, or mounted read only for the YAML and TOML config styles. The rendered file belongs to the user whose Home Manager produced it. A couple of service templates render outside HOME, into `/run/user/1002/`.

A Home Manager activation step pre-creates the data directories so volumes mount onto a real directory instead of a root owned one.

Changes get picked up on their own. A path unit watches `~/.config/containers/systemd` and a companion oneshot reloads units and restarts `default.target` if any container isn't active. Edit a quadlet and it takes effect, no manual reload, as long as that container is supposed to be running.

Updates use `AutoUpdate=registry` on anything pulling from a registry, re-pulled by a `podman-auto-update` user timer firing around 5am with up to two hours of jitter. Each of those images is pinned to an explicit tag, and every pinned tag is in `scripts/update-pinned-images.sh`, so nothing chases a moving tag on its own. Suffixes stay pinned too, so vaultwarden keeps its alpine variant and postgres stays on 16.x while patch versions float. Two images sit out of the bump: meilisearch, which stays on whatever version Karakeep is tested against, and website, which CI builds and pushes to our own registry. The two local builds, `mcp-gateway` and `open-terminal`, are pinned by digest in their Containerfiles.

Restart policies split almost evenly, 15 containers on `always` and 12 on `on-failure`. The `always` ones are what you'd notice being down.

## Users

| User | UID | Runs | Role |
| --- | --- | --- | --- |
| `user` | 1000 | your login, the only user allowed over SSH | interactive work |
| `deploy` | 1001 | the normal services | the container user, no root, no SSH |
| `guest` | 1002 | Wings, the Forgejo runner, the Pangolin Site connector on anotherpublicvm | untrusted workloads: third party game servers and CI jobs |

`deploy` and `guest` both have `linger = true`, so their user services and rootless podman instances come up at boot and outlive a logout. `deploy` is on the VPS, homelabvm and publicvm. `guest` is on publicvm and anotherpublicvm, which has no `deploy` user at all since nothing there needs one.

That split is the security boundary. A Pelican server or a Forgejo Actions job runs as `guest`, so it can't read `/home/deploy`, can't read `deploy`'s sops secrets, and can't touch the containers `deploy` runs. The two `guest` units are hardened to match: `ProtectSystem=strict`, `ProtectHome=read-only`, `ReadWritePaths` limited to the two persistence directories, `NoNewPrivileges`, `RestrictNamespaces` and `ProtectProc=invisible`.

`AllowUsers` permits only the login user, so getting to a container user means `run0 su deploy`, never SSH.

## Port map

Everything in the 5xxxx and 6xxxx range is bound to `127.0.0.1` and reachable only through a reverse proxy. Gerbil and MariaDB on the VPS are the exceptions, plus the host network containers, and those are at the bottom.

| Host | User | Service | Port | What it is |
| --- | --- | --- | --- | --- |
| vps | deploy | gerbil | 80, 443, 51820/udp, 21820/udp, 42712, 63536/udp | Pangolin tunnel, the only public entry point |
| vps | deploy | mariadb | 3306 on all interfaces | MariaDB, for the Pangolin panel |
| vps | deploy | crowdsec | `127.0.0.1:8080` | LAPI for the Pangolin stack |
| vps | deploy | pangolin, traefik | none | internal, on the pangolin network |
| homelabvm | deploy | nginx-proxy-manager | host network | reverse proxy and certificates |
| homelabvm | deploy | vaultwarden | `127.0.0.1:51001` | password manager |
| homelabvm | deploy | ntfy | `127.0.0.1:53001` | push notifications |
| homelabvm | deploy | ittools | `127.0.0.1:57001` | web utilities |
| homelabvm | deploy | navidrome | `127.0.0.1:56001` | music |
| homelabvm | deploy | freshrss | `127.0.0.1:58001` | feed reader |
| homelabvm | deploy | aonsoku | `127.0.0.1:60001` | nice looking UI for Navidrome |
| homelabvm | deploy | vikunja | `127.0.0.1:61000` | tasks |
| homelabvm | deploy | karakeep | `127.0.0.1:63001` | bookmarks |
| homelabvm | deploy | openwebui | `127.0.0.1:64001` | local LLM UI |
| homelabvm | deploy | degoog | `127.0.0.1:65001` | Google free search |
| homelabvm | deploy | mcp-gateway, open-terminal | none | inside OpenWebUI's network |
| homelabvm | deploy | wyzebridge | `127.0.0.1:50001` and up | Wyze devices to RTSP, five ports, defined but not imported |
| publicvm | deploy | pangolin-site | host network | Pangolin Site connector, the tunnel agent |
| publicvm | deploy | pelican-panel | `127.0.0.1:55001` | game server panel |
| publicvm | deploy | forgejo | `127.0.0.1:59001` | git |
| publicvm | deploy | website | `127.0.0.1:62001` | the site built from the Forgejo registry |
| publicvm | deploy | privatebin | `127.0.0.1:52001` | encrypted paste, data on tmpfs |
| publicvm | guest | wings | `0.0.0.0:54001` | Pelican agent API, plaintext, firewall closed |
| anotherpublicvm | guest | pangolin-site | host network | Pangolin Site connector, the tunnel agent |
| anotherpublicvm | guest | forgejo-runner | none | CI, talks to the Forgejo instance |
| anotherpublicvm | guest | wings | `0.0.0.0:54001` | Pelican agent API |

A few containers never publish anything: `freshrss-postgres`, `karakeep-meilisearch` and `karakeep-chrome` live on internal networks with their parent app.

publicvm and anotherpublicvm open no firewall ports beyond SSH, so everything published there stays host local.

## vps, the public side

This one runs the tunnel, the proxy and the WAF. It is the only machine meant to be reachable from outside.

| Container | Image | Role |
| --- | --- | --- |
| pangolin | `docker.io/fosrl/pangolin:1.24.0` | control plane for the reverse tunnel |
| gerbil | `docker.io/fosrl/gerbil:1.5.2` | WireGuard side of the tunnel, holds 80 and 443 |
| traefik | `docker.io/traefik:v3.7.15` | the reverse proxy, joined to Gerbil's namespace |
| crowdsec | `crowdsecurity/crowdsec:v1.8.1` | parses Traefik's logs with the appsec collections |
| mariadb | `lscr.io/linuxserver/mariadb:11.8.8` | database, used by the Pangolin panel |

Pangolin, Gerbil and CrowdSec share a `pangolin` network defined as a quadlet network unit, `172.20.0.0/24` with IPv6, so the panel, the tunnel agent and the proxy can find each other by name.

Traefik does things differently. It publishes no ports and instead joins Gerbil's network namespace with `Network=gerbil.container`. That is what lets TLS terminate on 443 and 80 without a second container or a host port. Its unit is ordered after `pangolin.service` and `crowdsec.service`, so the WAF is standing before the proxy starts taking traffic.

Gerbil gets `AddDevice=/dev/net/tun` and `AddCapability=NET_ADMIN`, since it is a WireGuard endpoint. It is the only container here running with extra privileges, and it sits on the machine with the public IP.

The host preloads `wireguard` as a kernel module. The firewall allows TCP 80, 443, 3306 and 42712 plus UDP 51820, 21820, 42712 and 63536, with IPv4 and IPv6 forwarding on. `ip_unprivileged_port_start` is dropped to 80 here as well.

## homelabvm, the services

Ten published services sit behind Nginx Proxy Manager, which runs on the host network because it needs 80 and 443. `ip_unprivileged_port_start` is lowered to 80 here too, otherwise an unprivileged user couldn't bind those ports at all. The host config calls that a security degradation, and it is one. The container has no network namespace of its own and sees every interface.

Three stacks get their own network units:

- Karakeep shares a `karakeep` network with `karakeep-meilisearch` and `karakeep-chrome`, so the app can reach Meilisearch and a headless Chrome for metadata extraction by hostname. It talks to OpenRouter for tagging and embeddings, with the API key from sops. The search index is pinned to Meilisearch 1.41.0.
- FreshRSS shares a `freshrss` network with its own `postgres:16.15-alpine`, so the database never gets published at all.
- The MCP stack is a single container, `mcp-gateway`, on `Network=container:openwebui`. It joins OpenWebUI's namespace directly, publishes nothing, has no route from the host, and is reachable only by OpenWebUI. It is a Rust gateway that spawns every backend (navidrome, Soulseek, FreshRSS, ntfy, lrclib, musicbrainz, open-meteo, NixOS docs, SafeDep vet and Playwright) as a stdio child. OpenWebUI connects to one endpoint and sees the gateway's meta tools instead of ten separate MCP servers. The `/mcp` endpoint needs the bearer token from sops.

ntfy is the push server sitting behind the gateway's `ntfy` backend. Its own auth is not configured at all, which means anonymous read and write on every topic, so the Nginx Proxy Manager access list is the only thing standing in front of it. It trusts the proxy (`NTFY_BEHIND_PROXY`), serves on 53001 and keeps its message cache in `~/containers/ntfy/data`.

open-terminal is the most privileged thing in this file. It runs arbitrary shell commands, and all the containment is in the mounts. The Navidrome music directory is read write at `/music`; the only other host paths are its own `~/containers/open-terminal/workdir` at `/workdir` and a rendered config. `/workdir` is also its working directory, so anything it downloads or generates survives a restart. `OPEN_TERMINAL_FILE_BROWSER_ROOT=/workdir` points OpenWebUI's file browser there.

None of that is a sandbox. Anything reachable from the container network is one `curl` away from a shell on that network. OpenWebUI reaches it at `http://localhost:8010` through its own namespace, and it has to be added under Integrations, then Open Terminal, rather than as a tool server.

The image is a local build: one `FROM` layer over `ghcr.io/open-webui/open-terminal`, pinned by digest, with the upstream entrypoint replaced by nothing. Dropping the entrypoint is the trick. Upstream drops to its `user` account through `su-exec`, which calls `setgroups`, and a rootless user namespace refuses that, so the published Alpine image won't start under `UserNS=keep-id` at all. Staying root sidesteps it, and root inside the container is `deploy` on the host, which is what `UserNS=keep-id:uid=0,gid=0` is for anyway.

On top of the base it installs ffmpeg, ripgrep, fd, pip, coreutils and a few small file tools, skipping the 4 GB `latest` image with LibreOffice and LaTeX. Being a build quadlet it has no `AutoUpdate`, so the base digest is the pin.

The API key comes from sops and the port lives in the rendered `/etc/open-terminal/config.toml`. The image only reads `host` and `port` from a config file, and 8000 is already soulseek-mcp in there.

mcp-gateway is a local build too. Its `mcp-gateway.build` quadlet starts from the pinned upstream base, which ships only the gateway binary with no Node and no uv, then adds Node 24 and uv and bakes every backend in at build time so nothing is fetched at runtime. Also a build quadlet, so no `AutoUpdate`, meaning it only changes when the upstream version or a package pin in the module does. It mounts the Navidrome music directory read write for the Soulseek download backend, and gets `TimeoutStartSec=900` because the first build installs toolchains and Python environments for slsk-mcp and mcp-nixos.

navidrome has a plain user service next to it: a small Python script using `watchdog` that keeps playlists in sync when files change under `~/containers/navidrome/music`. Same user, no hardening directives at all, which makes it the least defended process in the whole setup.

## publicvm and anotherpublicvm, the untrusted side

`deploy` runs Forgejo, the Pelican panel, the site, PrivateBin and the Pangolin Site connector on publicvm. `guest` runs the two things that execute code somebody else wrote.

The Pangolin Site connector is the site side agent for the tunnel back to the VPS, and it runs on both VMs. It's `docker.io/fosrl/pangolin-cli`, the official CLI, which replaces the older standalone `fosrl/newt` connector while still speaking the same site credentials. The image entrypoint runs `pangolin-cli up site` by itself as soon as `SITE_ID` and `SITE_SECRET` are set, so the unit passes the endpoint, id and secret as `Environment=` and sets no `Exec=` at all. No capabilities, no `/dev/net/tun`, since the connector defaults to the userspace WireGuard netstack instead of a native interface. `HEALTH_FILE=/tmp/healthy` makes it create that file only while the tunnel is up, which is what `HealthCmd` checks for. The sops keys are still called `newt-id`, `newt-secret` and `newt-pangolin-endpoint`. They're the site credentials, the names were just left alone.

The Forgejo Actions runner is the runner daemon, driven by a rendered `runner-config.yml` holding the connection URL, UUID and token from sops. It runs jobs as `ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest` with `privileged: false`, no IPv6, no volumes (`valid_volumes: []`), and `workdir_parent` on the persisted directory. It talks to podman over `unix:///run/user/1002/podman/podman.sock` via `DOCKER_HOST`, capacity 1, three hour timeouts. The label points at a third party registry image and `force_pull: false` means a cached copy gets reused.

Wings is the Pelican agent that starts the game server containers. Built from a local package rather than pulled from a registry, rendered config with the node id, token and panel URL from sops, and rootless containers as uid 1002 inside a `pelican_nw` bridge network with k8s style log rotation capped at 5 MB and 1 file. `BlockBaseDirMount` is on and `allowed_mounts` is empty. The API listens on `0.0.0.0:54001` with TLS off, kept away from the internet by the firewall but plaintext on every interface.

Both units get the same hardening as the runner: `ProtectSystem=strict`, `ProtectHome=read-only` and `ReadWritePaths` on their state directories. Both write into `/persist`, so `/var/lib/pelican`, `/var/log/pelican` and `/var/lib/forgejo-runner` are persistence mounts owned by `guest`, mode 0700 and 0750.

Two hosts run the same pair, so there are two Wings nodes and two runner instances at capacity 1 each, all pointed at the same Forgejo server.

## Networks in one place

| Style | Who uses it | What it means |
| --- | --- | --- |
| default, pasta | most containers | private netns, outbound only, loopback published ports |
| explicit quadlet network | karakeep, freshrss, pangolin | containers share a bridge by name, nothing published |
| `Network=container:<name>` | mcp-gateway, open-terminal | share another container's netns, no host visibility |
| `Network=host` | nginx-proxy-manager, pangolin-site | no isolation, sees host interfaces and loopback |
| `Network=gerbil.container` | traefik | shares the tunnel container's namespace, so it holds 443 |

## Operational notes

Ports get allocated by hand. Nothing checks for duplicates, so two containers on the same `127.0.0.1` port means the second fails to start with a port in use error. The 5xxxx and 6xxxx bands are a convention, not an allocation.

No container has resource limits. No `MemoryMax`, `CPUQuota` or `PidsLimit` anywhere, and `/` is a tmpfs at 50% of RAM, so running out of memory looks like a very full root filesystem.

Health checks are the exception. Only the Pangolin panel, the Pangolin CrowdSec container and the Pangolin Site connector have one. Everything else leans on the restart policy, which catches a crash but not a container that's up and quietly broken.

Rollback is manual. A bad image means pulling the previous tag yourself.

None of this gets backed up. Every database, upload and config sits on one disk per VM. The laptop has an hourly proxmox-backup-client timer; the servers have nothing equivalent.

Rootless podman depends on user namespaces. A future kernel or sysctl change restricting unprivileged namespaces stops every container on every host at once.

Hosts update by hand, no automatic rebuild timer anywhere. `rebuild` pulls the repo and switches the system when you run it, showing the incoming commits first. Image tags in the repo get bumped by scheduled Forgejo Actions.

## Adding a container

1. New file in `home/modules/server/containers/`, named after the service.
2. Declare `homelab.containerDirs` with every path you plan to mount, so the directories exist and belong to you.
3. If it needs credentials: `sops.secrets` for the values, then a `sops.templates` unit written to `~/.config/containers/systemd/<name>.container` and referenced through `config.sops.placeholder`.
4. `home.file.".config/containers/systemd/<name>.container"` with the unit: `After=network-online.target`, `ContainerName`, `Image`, `Restart=on-failure`, `WantedBy=default.target`.
5. `PublishPort=127.0.0.1:5xxxx:<container port>` on a port nobody else has. Never bind a web service to a real interface.
6. Import the module in the right `home/deploy-<host>.nix` or `home/guest-<host>.nix`.
7. Open a firewall port on the host only if something genuinely has to connect from outside, and only ever on the VPS.

The quadlet reload path unit picks up the new file on its own, so there is no manual reload to remember.