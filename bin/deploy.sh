#!/bin/bash

echo "# Build and deploy use case"
echo "---------------------------"

CONFIG_PATH="$1"
SERVICE_NAME="$2"
read -r DOCKER_USER < "$HOME/kiso-colmena-experiment/secrets/docker_username.txt"

# --- Validate inputs ---
if [ -z "$CONFIG_PATH" ] || [ -z "$SERVICE_NAME" ]; then
  echo "Usage: $0 <path-to-example_config> <service-name>"
  echo "Example: $0 ~/kiso-colmena-experiment/example_config AgentControl"
  exit 1
fi

# --- Convert to absolute path to avoid Docker relative path error ---
CONFIG_PATH="$(realpath "$CONFIG_PATH")"

# --- Read secrets if needed ---
if [[ -z "$AGENT_AREA" && -f secrets/agent_area ]]; then
  read -r AGENT_AREA < secrets/agent_area
fi

if [[ -z "$AGENT_NUM" && -f secrets/agent_num ]]; then
  read -r AGENT_NUM < secrets/agent_num
fi

# --- Validate required environment variables ---
if [[ -z "$AGENT_NUM" || -z "$AGENT_AREA" ]]; then
  echo "Error: AGENT_NUM and AGENT_AREA environment variables are required."
  echo "Example: export AGENT_NUM=1; export AGENT_AREA=3"
  exit 1
fi

# --- Derived variables ---
AGENT_ID="agent_${AGENT_NUM}_${AGENT_AREA}"

echo "Using agent: $AGENT_ID"
echo "Using config path: $CONFIG_PATH"
echo "Using Docker Hub user: $DOCKER_USER"
echo "Using service name: $SERVICE_NAME"

# --- Run deployment tool ---
docker run \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "${CONFIG_PATH}":/app \
  -v "${CONFIG_PATH}/agent/peer/zenoh_config.json5":/colmena/deployment/zenoh_config.json5:ro \
  --network=host \
  "${DOCKER_USER}/deployment-tool:latest" \
  --build_path=/app --platform=linux/amd64 --user="${DOCKER_USER}" \
  --skip_build

$HOME/kiso-colmena-experiment/bin/wait-for-docker-log.sh "${AGENT_ID}"-role-selector-1 "${SERVICE_NAME}"

echo "Deployment for ${AGENT_ID} (service: ${SERVICE_NAME}) completed successfully!"
