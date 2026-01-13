#!/usr/bin/env bash
set -euo pipefail

ZENOH_CONFIG="${1:?Usage: $0 <zenoh_config_file>}"
ZENOH_PORT=7447
ZENOH_CONFIG="$(readlink -f "$ZENOH_CONFIG")"

# ----------------------------
# Remove old config if it exists
# ----------------------------
if [[ -f "$ZENOH_CONFIG" ]]; then
    rm -f "$ZENOH_CONFIG"
fi

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
# Only m1-n1, m2-n1, m3-n1 are backbones
# Exception: m4-n1 is never backbone
# ----------------------------
IS_BACKBONE=false
if [[ "$NODE" == "1" ]]; then
    case "$MACHINE" in
        1|2|3) IS_BACKBONE=true ;;
        4) IS_BACKBONE=false ;;  # exception
        *) IS_BACKBONE=false ;;
    esac
fi

# ----------------------------
# Compute endpoints
# ----------------------------
ENDPOINTS=()
if [[ "$IS_BACKBONE" == true ]]; then
  case "$SITE" in
    HAWI)
      ENDPOINTS+=(
        "tcp/[colmena-sUTAH-m3-n1]:${ZENOH_PORT}"
        "tcp/[colmena-sWASH-m1-n1]:${ZENOH_PORT}"
      )
      ;;
    WASH)
      ENDPOINTS+=(
        "tcp/[colmena-sHAWI-m2-n1]:${ZENOH_PORT}"
        "tcp/[colmena-sUTAH-m3-n1]:${ZENOH_PORT}"
      )
      ;;
    UTAH)
      ENDPOINTS+=(
        "tcp/[colmena-sHAWI-m2-n1]:${ZENOH_PORT}"
        "tcp/[colmena-sWASH-m1-n1]:${ZENOH_PORT}"
      )
      ;;
    *)
      echo "ERROR: unknown site $SITE" >&2
      exit 1
      ;;
  esac
else
  # non-backbone nodes always point to the local site's backbone
  case "$SITE" in
    HAWI)
      BACKBONE_HOST="colmena-sHAWI-m2-n1"
      ;;
    WASH)
      BACKBONE_HOST="colmena-sWASH-m1-n1"
      ;;
    UTAH)
      BACKBONE_HOST="colmena-sUTAH-m3-n1"
      ;;
    *)
      echo "ERROR: unknown site $SITE" >&2
      exit 1
      ;;
  esac

  ENDPOINTS+=("tcp/[${BACKBONE_HOST}]:${ZENOH_PORT}")
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
