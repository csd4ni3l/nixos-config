# Bump pinned container Image= tags in quadlet modules, leaving the edits in
# the working tree for the workflow to commit.

set -euo pipefail

entries=(
  "home/modules/server/containers/pangolin.nix|docker.io/fosrl/pangolin||[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/pangolin.nix|docker.io/fosrl/gerbil||[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/pangolin.nix|docker.io/traefik|v|[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/pangolin.nix|docker.io/crowdsecurity/crowdsec|v|[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/mariadb.nix|lscr.io/linuxserver/mariadb||[0-9]+\.[0-9]+\.[0-9]+|"

  "home/modules/server/containers/pangolin-site.nix|docker.io/fosrl/pangolin-cli||[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/forgejo.nix|codeberg.org/forgejo/forgejo||16\.[0-9]+\.[0-9]+|-rootless"
  "home/modules/server/containers/pelican-panel.nix|ghcr.io/pelican/panel||[0-9]+\.[0-9]+\.[0-9]+(-rc\.[0-9]+)?|"

  "home/modules/server/containers/nginx-proxy-manager.nix|docker.io/jc21/nginx-proxy-manager||[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/vaultwarden.nix|docker.io/vaultwarden/server||[0-9]+\.[0-9]+\.[0-9]+|-alpine"
  "home/modules/server/containers/privatebin.nix|docker.io/privatebin/nginx-fpm-alpine||[0-9]+\.[0-9]+\.[0-9]+|-alpine3\.[0-9]+"
  "home/modules/server/containers/ntfy.nix|docker.io/binwiederhier/ntfy|v|[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/karakeep.nix|ghcr.io/karakeep-app/karakeep||[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/karakeep.nix|ghcr.io/karakeep-app/karakeep-chrome||[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+-r[0-9]+|"
  "home/modules/server/containers/openwebui.nix|ghcr.io/open-webui/open-webui|v|[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/navidrome.nix|docker.io/deluan/navidrome||[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/aonsoku.nix|ghcr.io/victoralvesf/aonsoku||[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/ittools.nix|ghcr.io/sharevb/it-tools||[0-9]{4}\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/degoog.nix|ghcr.io/degoog-org/degoog||[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/vikunja.nix|docker.io/vikunja/vikunja||[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/freshrss.nix|lscr.io/linuxserver/freshrss||[0-9]+\.[0-9]+\.[0-9]+|"
  "home/modules/server/containers/freshrss.nix|docker.io/postgres||16\.[0-9]+|-alpine"
)

changed=false

for entry in "${entries[@]}"; do
  IFS='|' read -r file repo prefix pattern suffix <<<"$entry"

  line=$(grep -m1 -E "^[[:space:]]*Image=${repo}:" "$file") || {
    echo "error: no Image= line for ${repo} in ${file}" >&2
    exit 1
  }
  current=$(sed -E "s|^[[:space:]]*Image=${repo}:||" <<<"$line" | tr -d '[:space:]')
  [[ -n $current ]] || {
    echo "error: ${repo} in ${file} has no tag to bump" >&2
    exit 1
  }

  candidate=$(skopeo list-tags "docker://${repo}" | jq -r '.Tags[]?' \
    | grep -E "^${prefix}${pattern}${suffix}$" \
    | sort -V | tail -1 || true)

  if [[ -z $candidate ]]; then
    echo "error: no tag of ${repo} matches ${prefix}${pattern}${suffix}" >&2
    echo "       currently pinned: ${current}" >&2
    exit 1
  fi

  if [[ "$candidate" == "$current" ]]; then
    echo "${repo}: ${current} (current)"
    continue
  fi

  sed -i -E "s|(^[[:space:]]*Image=${repo}:).*|\1${candidate}|" "$file"
  echo "${repo}: ${current} -> ${candidate}"
  changed=true
done

if [[ "$changed" == false ]]; then
  echo "all pinned images already current"
fi
