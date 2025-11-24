# teams_events_7d_v7_merged.sh – Design & Operator Notes (Day 237)

This document accompanies the canonical **v7 merged Teams custom-events fetcher** created on Day 237 after Umami Cloud moved the *Events* feature behind paid plans.

## Context
* 24 Nov 2025 – legacy `/events?eventType=2` endpoint removed; free plan now 404s.
* Hobby ($9/mo) tier exposes new REST path:
  `/api/websites/<UUID>/events?startAt=<ms>&endAt=<ms>`
* Our custom metrics pipeline (Teams slice) broke; P0 incident opened.

## Goals for v7
1. Support new paid-tier endpoint.
2. Dual-auth: cookie JWT (`UMAMI_TOKEN`) preferred, fallback Bearer via env `UMAMI_BEARER`.
3. Parameterised look-back window (`LOOKBACK_DAYS`, default 7).
4. Zero external deps (no `jq`); pure `curl` + `date` + `awk`.
5. Robust error handling with `die()` helper.
6. Flexible output – stdout to pipe **or** `-o/--out` file flag.

## Key implementation highlights
```bash
# calc window in ms
START_MS=$(date -d "-$LOOKBACK_DAYS days" +%s000)
END_MS=$(date +%s000)

curl -fsSL \
  -H "Cookie: __Secure-next-auth.session-token=$UMAMI_TOKEN" \
  -H "Authorization: Bearer $UMAMI_BEARER" \
  "$UMAMI_HOST/api/websites/$SITE_ID/events?startAt=$START_MS&endAt=$END_MS"
```
* If both auth env vars set, cookie takes precedence (higher quota, no CORS pre-flight).
* `die()` prints red text and exits non-zero so CI surfaces failure quickly.

## Usage
```bash
# 1. obtain fresh session token via browser -> DevTools -> Application -> Cookies
export UMAMI_TOKEN=$(clean_jwt.sh <<<"<raw-cookie>")

# 2. run fetcher; write to slice file
./teams_events_7d_v7_merged.sh -o teams_events_last7.json
```

## Future work
* Automate token refresh via headless login.
* Parameterise website UUID so script can service multiple sites.
* Once finance approves Hobby plan, integrate into nightly pipeline.

