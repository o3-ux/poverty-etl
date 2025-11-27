#!/usr/bin/env bash
set -euo pipefail

# Usage: netlify_auto_siteid.sh [repo-slug]

if [[ -z "${NETLIFY_AUTH_TOKEN:-}" ]]; then
  echo "NETLIFY_AUTH_TOKEN is not set." >&2
  exit 1
fi

repo_slug="${1:-}"
if [[ -z "$repo_slug" ]]; then
  if [[ -n "${GITHUB_REPOSITORY:-}" && "$GITHUB_REPOSITORY" == */* ]]; then
    repo_slug="${GITHUB_REPOSITORY#*/}"
  else
    echo "Repository slug not provided and GITHUB_REPOSITORY is unavailable." >&2
    exit 1
  fi
fi

sites_json="$(curl -sSf -H "Authorization: Bearer ${NETLIFY_AUTH_TOKEN}" "https://api.netlify.com/api/v1/sites")"

site_id="$(jq -r --arg slug "$repo_slug" '.[] | select(.name == $slug) | .id' <<<"$sites_json" | head -n1)"

if [[ -z "${site_id:-}" || "$site_id" == "null" ]]; then
  echo "No Netlify site found for slug '$repo_slug'." >&2
  echo "Available site names:" >&2
  jq -r '.[].name' <<<"$sites_json" >&2
  exit 1
fi

echo "$site_id"
exit 0
