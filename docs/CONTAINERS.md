## How it works

Every container is a rootless podman quadlet. Home Manager writes each one as a plain text unit into `~/.config/containers/systemd/<name>.container`, and podman turns that directory into systemd units at start. A container is just an ordinary user service under `default.target`. No `podman run` anywhere, no compose file.

Networking goes through pasta as the rootless default. A container that doesn't declare `Network=` gets its own network namespace, outbound access and nothing coming in.

Ports are published one at a time, and everything web facing binds to loopback and gets reached through a reverse proxy. Never directly.

Data lives in `~/containers/<service>/` on the persisted filesystem. Ownership uses `UserNS=keep-id` where an image needs to write as a particular uid, so files the container writes are files you can read.

Secrets come from sops and are rendered into the user's sops-nix directory, then passed in as environment variables or mounted read only for config files.

A Home Manager activation step pre-creates the data directories so volumes mount onto a real directory instead of a root owned one.

Changes get picked up on their own. A path unit watches the quadlet directory and reloads units when anything changes, so editing a container takes effect without a manual reload.

Nothing self-updates. Images are pinned to explicit tags, bumped by `scripts/update-pinned-images.sh` through a scheduled PR, and applied on rebuild. Two images sit out of the bump on purpose, meilisearch because Karakeep is tested against a specific version, and website because CI builds it. The two local builds are pinned by digest.

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
| vps | deploy | mariadb | 3306 on all interfaces | MariaDB, for the Pelican panel |
| vps | deploy | crowdsec | `127.0.0.1:8080` | LAPI for the Pangolin stack |
| vps | deploy | pangolin, traefik | none | internal, on the pangolin network |
| homelabvm | deploy | nginx-proxy-manager | host network | reverse proxy and certificates |
| homelabvm | deploy | vaultwarden | `127.0.0.1:51001` | password manager |
| homelabvm | deploy | ntfy | `127.0.0.1:53001` | push notifications |
| homelabvm | deploy | ittools | `127.0.0.1:57001` | web utilities |
| homelabvm | deploy | navidrome | `127.0.0.1:56001` | music |
| homelabvm | deploy | freshrss | `127.0.0.1:58001` | feed reader |
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
| publicvm | guest | wings | `127.0.0.1:54001` | Pelican agent API |
| anotherpublicvm | guest | pangolin-site | host network | Pangolin Site connector, the tunnel agent |
| anotherpublicvm | guest | forgejo-runner | none | CI, talks to the Forgejo instance |
| anotherpublicvm | guest | wings | `127.0.0.1:54001` | Pelican agent API |

Nothing is published for `freshrss-postgres`, `karakeep-meilisearch` or `karakeep-chrome`. They live on internal networks with their parent app.

publicvm and anotherpublicvm open no firewall ports beyond SSH, so everything published there stays host local.

## vps, the public side

This one runs the tunnel, the proxy and the WAF. It is the only machine meant to be reachable from outside.

| Container | Role |
| --- | --- |
| pangolin | control plane for the reverse tunnel |
| gerbil | WireGuard side of the tunnel, holds 80 and 443 |
| traefik | the reverse proxy, joined to Gerbil's namespace |
| crowdsec | watches Traefik's logs and bans what it finds |
| mariadb | database for the Pelican panel |

Pangolin, Gerbil and CrowdSec share a quadlet network, so the panel, the tunnel agent and the proxy find each other by name.

Traefik publishes no ports and instead joins Gerbil's network namespace, which is what lets TLS terminate on 443 and 80 without a second container. Its unit starts after CrowdSec, so the WAF is standing before the proxy takes traffic.

Gerbil is the one container with extra privileges, since it's a WireGuard endpoint and needs the TUN device.

## homelabvm, the services

Ten published services sit behind Nginx Proxy Manager, which runs on the host network because it needs 80 and 443. Lowering the privileged port threshold so an unprivileged user can bind those is a real degradation: the proxy has no network namespace of its own and sees every interface.

Three stacks get their own internal networks:

- Karakeep reaches its own Meilisearch and a headless Chrome for metadata by hostname. Tagging and embeddings go to OpenRouter.
- FreshRSS has its own Postgres, never published.
- The MCP gateway sits inside OpenWebUI's network namespace. One endpoint instead of ten MCP servers, with every backend spawned as a child process. Nothing reaches it except OpenWebUI, and it needs the bearer token.

open-terminal is the most privileged thing in this file. It runs arbitrary shell commands and all the containment is in the mounts: the music directory read write, its own work directory, and Mornye's shared downloads directory. Anything reachable from the container network is one `curl` away from a shell on it. OpenWebUI reaches it through its own namespace and it has to be added as an Open Terminal integration rather than a tool server.

The upstream image drops privileges through `setgroups`, which a rootless namespace refuses, so the entrypoint is replaced and it stays root, meaning `deploy` on the host. And it's a local build pinned by digest, so it doesn't track the upstream `latest` image, which is several gigabytes.

mcp-gateway is a local build for the same reason, baking its backends in at build time so nothing is fetched at runtime.

navidrome has a plain user service next to it that keeps playlists in sync when files change. It has no hardening directives at all, which makes it the least defended process in the whole setup.

## publicvm and anotherpublicvm, the untrusted side

`deploy` runs Forgejo, the Pelican panel, the site, PrivateBin and the Pangolin Site connector on publicvm. `guest` runs the two things that execute code somebody else wrote.

The Pangolin Site connector is the site side agent for the tunnel back to the VPS, and it runs on both VMs. It's the official Pangolin CLI, which replaced the older standalone connector while still speaking the same site credentials. No capabilities and no TUN device needed, since it uses the userspace WireGuard stack.

You'll trip over one thing. The sops keys are still called `newt-id` and friends. They're the site credentials, the names were just left alone.

The Forgejo Actions runner executes CI jobs as rootless containers under the `guest` user. Unprivileged, no volumes, no IPv6, capacity 1, and its podman socket belongs to `guest` rather than the login user.

Wings is the Pelican agent that starts the game server containers. Built from a local package, configured from sops, and running the game servers as uid 1002 in its own bridge network.

Its API is the one soft spot here. It binds loopback so nothing else on the LAN can reach it.

Both units get the same hardening as the runner, a read only home and write access limited to their state directories. Both write into `/persist`, so their state paths are persistence mounts owned by `guest`.

Two hosts run the same pair, so there are two Wings nodes and two runner instances at capacity 1 each, all pointed at the same Forgejo server.

## Operational notes

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
