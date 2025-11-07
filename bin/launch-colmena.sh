#!/bin/bash
set -e

ZENOH_ROUTER_IP="172.17.0.1"
ENDPOINT="172.17.0.1:20000"

# --- Parse arguments ---
CONFIG_PATH=""
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --hardware) HARDWARE="$2"; shift ;;
    --policy) POLICY="$2"; shift ;;
    --config-path) CONFIG_PATH="$2"; shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# --- Validate required params ---
if [[ -z "$HARDWARE" || -z "$POLICY" || -z "$CONFIG_PATH" ]]; then
  echo "Usage: $0 --hardware <value> --policy <value> --config-path <path-to-example_config>"
  echo
  echo "Note: Environment variables AGENT_NUM and AGENT_AREA must be set."
  echo "Example:"
  echo "  export AGENT_NUM=1"
  echo "  export AGENT_AREA=3"
  echo "  ./launch_colmena.sh --hardware GPU --policy test --config-path example_config/"
  exit 1
fi

# --- Validate required environment variables ---
if [[ -z "$AGENT_NUM" || -z "$AGENT_AREA" ]]; then
  echo "Error: AGENT_NUM and AGENT_AREA environment variables are required."
  echo "Example: export AGENT_NUM=1; export AGENT_AREA=3"
  exit 1
fi

# --- Build AGENT_ID dynamically ---
AGENT_ID="agent_${AGENT_NUM}_${AGENT_AREA}"
echo "Agent ID: $AGENT_ID"

# --- Launch ---
pwd
cd $CONFIG_PATH/agent

docker compose -f compose-zenoh.yaml up -d

HARDWARE="$HARDWARE" \
AGENT_ID="$AGENT_ID" \
POLICY="$POLICY" \
ZENOH_ROUTER="$ZENOH_ROUTER_IP" \
ENDPOINT="$ENDPOINT" \
docker compose -p "$AGENT_ID" -f compose.yaml up -d

BASE="$HOME/kiso-colmena-experiment/bin"

$BASE/wait-for-docker-log.sh zenoh-zenoh-router-1 "Register resource colmena_service_definitions/*" &
$BASE/wait-for-docker-log.sh "$AGENT_ID"-zenoh-client-1 "Finished getting published service definitions" &
$BASE/wait-for-docker-log.sh "$AGENT_ID"-dsm-1 "COLMENA service definition published" &
$BASE/wait-for-docker-log.sh "$AGENT_ID"-context-awareness-manager-1 "Server is ready to handle requests" &
$BASE/wait-for-docker-log.sh "$AGENT_ID"-role-selector-1 "Received service description for service:  Colmena" &
$BASE/wait-for-docker-log.sh "$AGENT_ID"-sla-manager-1 "Running and listening on port 8080 ..." &
$BASE/wait-for-docker-log.sh "$AGENT_ID"-metrics-etl-1 "Subscribed to colmena/contexts/**" &

wait
echo "All containers matched their log patterns!"