#!/usr/bin/env bash
# Smoke test – verifies production root and fallback text files.
set -euo pipefail

# Accept base URL via first positional argument or BASE_URL env var.
if [[ $# -ge 1 ]]; then
  base="$1"
elif [[ -n "${BASE_URL-}" ]]; then
  base="$BASE_URL"
else
  echo "Usage: $0 <base_url>  OR  BASE_URL=<url> $0" >&2
  exit 1
fi

# 1) Root page reachable and >100 B
read -r status size < <(curl -sS -w "%{http_code} %{size_download}" -o /dev/null "$base")
echo "$base -> status:$status size:$size"
[[ "$status" == 200 ]] || { echo "FAIL root status $status"; exit 2; }
[[ "$size" -gt 100 ]] || { echo "FAIL root size $size"; exit 3; }

# 2) Fallback raw text assets available and >300 B
fallbacks=(
  "https://files.catbox.moe/tgl4lv.txt"
  "https://files.catbox.moe/k9zo0r.txt"
)
for u in "${fallbacks[@]}"; do
  read -r s sz < <(curl -sS -w "%{http_code} %{size_download}" -o /dev/null "$u")
  echo "$u -> status:$s size:$sz"
  [[ "$s" == 200 ]] || { echo "FAIL $u status $s"; exit 4; }
  [[ "$sz" -gt 300 ]] || { echo "FAIL $u size $sz"; exit 5; }
done

echo "Smoke OK"
