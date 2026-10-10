# Bump pinned container Image= tags in quadlet modules, leaving the edits in
# the working tree for the workflow to commit.

set -euo pipefail

entries=(
  "home/modules/server/containers/pangolin.nix|docker.io/fosrl/pangolin|latest"
  "home/modules/server/containers/pangolin.nix|docker.io/traefik|latest"
  "home/modules/server/containers/karakeep.nix|docker.io/getmeili/meilisearch|latest"
  "home/modules/server/containers/ntfy.nix|docker.io/binwiederhier/ntfy|latest"
)

changed=false

for entry in "${entries[@]}"; do
  IFS='|' read -r file image mode <<<"$entry"

  line=$(grep -m1 -E "^[[:space:]]*Image=${image}:" "$file") || {
    echo "error: no Image= line for ${image} in ${file}" >&2
    exit 1
  }
  current=$(sed -E "s|^[[:space:]]*Image=${image}:||" <<<"$line" | tr -d '[:space:]')

  case "$mode" in
    latest)
      prefix=""
      if [[ "$current" == v* ]]; then
        prefix="v"
      fi
      tags=$(skopeo list-tags "docker://${image}")
      latest=$(jq -r '.Tags[]' <<<"$tags" \
        | grep -E "^${prefix}[0-9]+(\.[0-9]+)*$" \
        | sort -V \
        | tail -1 || true)
      ;;
    *)
      echo "error: unknown mode '${mode}' for ${image}" >&2
      exit 1
      ;;
  esac

  if [[ -z "${latest}" || "$latest" == "$current" ]]; then
    echo "${image}: current (${current})"
    continue
  fi

  sed -i -E "s|(^[[:space:]]*Image=${image}:).*|\1${latest}|" "$file"
  echo "${image}: ${current} -> ${latest}"
  changed=true
done

if [[ "$changed" == false ]]; then
  echo "all pinned images already current"
fi
