#!/bin/bash
set -e

echo "# Build and deploy use case"
echo "---------------------------"

CONFIG_PATH="$1"
DOCKER_USER="$2"
SERVICE_NAME="$3"

# --- Validate inputs ---
if [ -z "$CONFIG_PATH" ] || [ -z "$DOCKER_USER" ] || [ -z "$SERVICE_NAME" ]; then
  echo "Usage: $0 <path-to-example_config> <dockerhub-username> <service-name>"
  echo "Example: $0 ~/kiso-colmena-experiment/example_config xaviercasasbsc AgentControl"
  exit 1
fi

# --- Convert to absolute path to avoid Docker relative path error ---
CONFIG_PATH="$(realpath "$CONFIG_PATH")"

# --- Required environment variables ---
if [ -z "$AGENT_NUM" ]; then
  echo "Error: AGENT_NUM is not set."
  echo "Please export AGENT_NUM before running this script, e.g.:"
  echo "  export AGENT_NUM=1"
  exit 1
fi

if [ -z "$AGENT_AREA" ]; then
  echo "Error: AGENT_AREA is not set."
  echo "Please export AGENT_AREA before running this script, e.g.:"
  echo "  export AGENT_AREA=3"
  exit 1
fi

# --- Derived variables ---
AGENT_ID="agent_${AGENT_NUM}_${AGENT_AREA}"

echo "Using agent: $AGENT_ID"
echo "Using config path: $CONFIG_PATH"
echo "Using Docker Hub user: $DOCKER_USER"
echo "Using service name: $SERVICE_NAME"

# --- Run deployment tool ---
sudo -n docker run \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "${CONFIG_PATH}":/app \
  -v "${CONFIG_PATH}/agent/peer/zenoh_config.json5":/colmena/deployment/zenoh_config.json5:ro \
  --network=host \
  "${DOCKER_USER}/deployment-tool:latest" \
  --build_path=/app --platform=linux/amd64 --user="${DOCKER_USER}" \
  --skip_build

$HOME/kiso-colmena-experiment/bin/wait-for-docker-log.sh "${AGENT_ID}"-role-selector-1 "${SERVICE_NAME}"

echo "Deployment for ${AGENT_ID} (service: ${SERVICE_NAME}) completed successfully!"
