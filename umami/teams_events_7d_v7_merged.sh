#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# teams_events_7d_v7.sh  (canonical merged version)
# -----------------------------------------------------------------------------
# Fetch Microsoft Teams custom-event metrics for the last 7 days from Umami Cloud
# using the new v3 metrics API (post-Nov-2025).
#
#  ‣ Works ONLY on paid tiers (Hobby+). Legacy-free sites return HTTP 404.
#  ‣ Requires one of the following auth env vars:
#        UMAMI_TOKEN   – raw JWT ("Authorization: Bearer <token>")
#        UMAMI_COOKIE  – full Cookie header containing __Secure-next-auth.session-token
#    If both are supplied, UMAMI_TOKEN wins.
#  ‣ Emits raw JSON to stdout **and/or** to a file path given via JSON_OUT.
#  ‣ No jq dependency for normal operation; callers parse downstream.
# -----------------------------------------------------------------------------
set -euo pipefail

################################################################################
# helpers
################################################################################

die() {
  echo "$(basename "$0"): $*" >&2
  exit 1
}

################################################################################
# auth header
################################################################################

AUTH_HEADER=""
if [[ -n "${UMAMI_TOKEN:-}" ]]; then
  AUTH_HEADER="Authorization: Bearer ${UMAMI_TOKEN}"
elif [[ -n "${UMAMI_COOKIE:-}" ]]; then
  AUTH_HEADER="Cookie: ${UMAMI_COOKIE}"
else
  die "Missing auth. Export UMAMI_TOKEN or UMAMI_COOKIE. See clean_jwt.sh runbook."
fi

################################################################################
# config (override via env)
################################################################################

UMAMI_HOST=${UMAMI_HOST:-"https://cloud.umami.is"}
SITE_ID=${UMAMI_SITE_ID:-"437e9c1f-7eab-40da-a40a-25b4b42e8dc9"}  # Daily Connections
LOOKBACK_DAYS=${LOOKBACK_DAYS:-7}
EVENT_FILTER=${EVENT_FILTER:-"teams"}          # label inside custom event payload
JSON_OUT=${JSON_OUT:-""}                      # optional output file path

################################################################################
# time window in ms since epoch
################################################################################
END_MS=$(date +%s000)
START_MS=$(date -v -${LOOKBACK_DAYS}d +%s000 2>/dev/null || \
          date -d "-${LOOKBACK_DAYS} days" +%s000)

################################################################################
# build URL
################################################################################
URL="${UMAMI_HOST}/api/websites/${SITE_ID}/events?startAt=${START_MS}&endAt=${END_MS}"
if [[ -n "${EVENT_FILTER}" ]]; then
  # encode query param safely without jq requirement (POSIX)
  ENCODED=$(python3 - <<PY "import urllib.parse, os; print(urllib.parse.quote(os.environ['EVF']))" EVF="${EVENT_FILTER}" PY)
  URL+="&query=${ENCODED}"
fi

################################################################################
# fetch
################################################################################
TMP=$(mktemp)
HTTP_CODE=$(curl -sSL -w "%{http_code}" -o "$TMP" \
  -H "$AUTH_HEADER" \
  -H "Accept: application/json" "$URL")

if [[ "$HTTP_CODE" != "200" ]]; then
  cat "$TMP" >&2
  die "Umami API returned HTTP $HTTP_CODE (see above). Ensure paid tier & valid auth."
fi

# output
if [[ -n "$JSON_OUT" ]]; then
  mv "$TMP" "$JSON_OUT"
  chmod 600 "$JSON_OUT"
  echo "JSON written to $JSON_OUT" >&2
  cat "$JSON_OUT"
else
  cat "$TMP"
  rm "$TMP"
fi

# eof -------------------------------------------------------------------------
