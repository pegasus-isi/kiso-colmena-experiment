#!/usr/bin/env bash
set -euo pipefail

ZENOH_CONFIG="${1:?Usage: $0 <zenoh_config_file>}"
ZENOH_PORT=7447
ZENOH_CONFIG="$(readlink -f "$ZENOH_CONFIG")"

rm -f "$ZENOH_CONFIG"

# ----------------------------
# Detect identity
# ----------------------------
HOST="$(hostname)"
SITE="$(echo "$HOST" | sed -n 's/.*-s\([A-Z]\+\)-m.*/\1/p')"
NODE="$(echo "$HOST" | sed -n 's/.*-n\([0-9]\+\)$/\1/p')"
MACHINE="$(echo "$HOST" | sed -n 's/.*-m\([0-9]\+\)-.*/\1/p')"

if [[ -z "$SITE" || -z "$NODE" || -z "$MACHINE" ]]; then
  echo "ERROR: cannot parse hostname: $HOST" >&2
  exit 1
fi

# ----------------------------
# Determine backbone
# Backbone = n1 EXCEPT m7-n1
# ----------------------------
IS_BACKBONE=false
if [[ "$NODE" == "1" && "$MACHINE" != "7" ]]; then
    IS_BACKBONE=true
fi

# ----------------------------
# Site list (ring order)
# ----------------------------
ALL_SITES=(
  UTAH
  LOSA
  UCSD
  STAR
  BRIST
  FIU
)

# ----------------------------
# Site -> backbone machine
# ----------------------------
declare -A SITE_BACKBONE_MACHINE=(
  [UTAH]=2
  [LOSA]=1
  [UCSD]=3
  [STAR]=4
  [BRIST]=5
  [FIU]=6
)

# ----------------------------
# Compute endpoints
# ----------------------------
ENDPOINTS=()

if [[ "$IS_BACKBONE" == true ]]; then
  # Backbone routers form a ring
  num_sites="${#ALL_SITES[@]}"
  site_index=-1
  for i in "${!ALL_SITES[@]}"; do
    [[ "${ALL_SITES[$i]}" == "$SITE" ]] && site_index="$i" && break
  done
  if [[ "$site_index" -lt 0 ]]; then
    echo "ERROR: site $SITE not found in ALL_SITES ring" >&2
    exit 1
  fi

  prev_index=$(( (site_index - 1 + num_sites) % num_sites ))
  next_index=$(( (site_index + 1) % num_sites ))

  PREV_SITE="${ALL_SITES[$prev_index]}"
  NEXT_SITE="${ALL_SITES[$next_index]}"

  PREV_MACHINE="${SITE_BACKBONE_MACHINE[$PREV_SITE]}"
  NEXT_MACHINE="${SITE_BACKBONE_MACHINE[$NEXT_SITE]}"

  ENDPOINTS+=(
    "tcp/colmena-s${PREV_SITE}-m${PREV_MACHINE}-n1:${ZENOH_PORT}"
    "tcp/colmena-s${NEXT_SITE}-m${NEXT_MACHINE}-n1:${ZENOH_PORT}"
  )

else
  # Non-backbone nodes connect to the site's real backbone
  BACKBONE_MACHINE="${SITE_BACKBONE_MACHINE[$SITE]:?No backbone defined for $SITE}"
  BACKBONE_HOST="colmena-s${SITE}-m${BACKBONE_MACHINE}-n1"
  ENDPOINTS+=("tcp/${BACKBONE_HOST}:${ZENOH_PORT}")
fi

# ----------------------------
# Write the Zenoh config
# ----------------------------
{
echo "{"
echo "  mode: \"router\","
echo "  scouting: {"
echo "    timeout: 3000,"
echo "    delay: 500,"
echo "    multicast: { enabled: false },"
echo "    gossip: { enabled: true, multihop: true }"
echo "  },"
echo "  connect: {"
echo "    endpoints: ["
for ep in "${ENDPOINTS[@]}"; do
    echo "      \"$ep\","
done | sed '$ s/,$//'
echo "    ]"
echo "  },"
echo "  plugins: {"
echo "    storage_manager: {"
echo "      storages: {"
echo "        all: {"
echo "          key_expr: \"**\","
echo "          volume: \"memory\""
echo "        }"
echo "      }"
echo "    },"
echo "    rest: { http_port: 8000 }"
echo "  }"
echo "}"
} > "$ZENOH_CONFIG"

# ----------------------------
# Done
# ----------------------------
echo "Zenoh config updated and overwritten: $ZENOH_CONFIG"
echo "  site=$SITE node=$NODE machine=$MACHINE backbone=$IS_BACKBONE"
echo "  endpoints:"
for ep in "${ENDPOINTS[@]}"; do
    echo "    - $ep"
done
