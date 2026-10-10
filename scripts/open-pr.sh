set -euo pipefail

title=${1:?usage: open-pr.sh <title> <body-file>}
body_file=${2:?usage: open-pr.sh <title> <body-file>}
: "${UPDATE_TOKEN:?UPDATE_TOKEN must be set}"

for tool in git curl jq; do
  command -v "$tool" >/dev/null || { echo "error: ${tool} not found" >&2; exit 1; }
done

origin=$(git remote get-url origin)
host=$(printf '%s' "$origin" | sed -E 's#^https?://([^@]*@)?([^/]+)/.*#\2#')
repo=$(printf '%s' "$origin" | sed -E 's#^https?://([^@]*@)?[^/]+/##; s#\.git$##')
head_branch=$(git rev-parse --abbrev-ref HEAD)

payload=$(jq -n \
  --arg head "$head_branch" \
  --arg base main \
  --arg title "$title" \
  --rawfile body "$body_file" \
  '{head: $head, base: $base, title: $title, body: $body}')

response=$(mktemp)
trap 'rm -f "$response"' EXIT

code=$(curl -sS -o "$response" -w '%{http_code}' \
  -X POST "https://${host}/api/v1/repos/${repo}/pulls" \
  -H "Authorization: token ${UPDATE_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d "$payload")

if [[ "$code" == 201 ]]; then
  echo "opened pull request: $(jq -r '.html_url' "$response")"
elif [[ "$code" == 409 ]] || grep -qi 'already exists' "$response"; then
  echo "pull request already open for ${head_branch}"
else
  echo "error: failed to open pull request (HTTP ${code})" >&2
  cat "$response" >&2
  exit 1
fi
