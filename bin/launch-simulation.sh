#!/bin/bash

set -e

echo "# Install Simulation"
echo "--------------------"

# --- Input arguments ---
CONFIG_PATH="$(readlink -f "$1")"
OUTPUT_PATH="$(readlink -f "$2")"

if [ -z "$CONFIG_PATH" ] || [ -z "$OUTPUT_PATH" ]; then
  echo "Usage: $0 <path-to-config.py> <path-to-output-folder>"
  echo "Example: $0 ~/my_eroots/config.py ~/my_eroots/output_plots"
  exit 1
fi

# --- Static variables ---
DOCKER_NAME="andes"
DOCKER_IMAGE="xaviercasasbsc/andes_src"

# --- Validate paths ---
if [ ! -f "$CONFIG_PATH" ]; then
  echo "Config file not found: $CONFIG_PATH"
  exit 1
fi

mkdir -p "$OUTPUT_PATH"

# --- Ensure 'andes' is in /etc/hosts ---
if ! grep -qE '^[[:space:]]*127\.0\.0\.1[[:space:]]+andes(\s|$)' /etc/hosts; then
  echo "Adding '127.0.0.1 andes' to /etc/hosts"
  echo "127.0.0.1 andes" | sudo tee -a /etc/hosts > /dev/null
else
  echo "'andes' already present in /etc/hosts"
fi

# --- Remove any existing container ---
if docker ps -a --format '{{.Names}}' | grep -q "^${DOCKER_NAME}\$"; then
  echo "Removing existing container: $DOCKER_NAME"
  docker rm -f "$DOCKER_NAME"
fi

# --- Run simulation container ---
echo "Starting Docker container: $DOCKER_NAME"
docker run -d \
  --name "$DOCKER_NAME" \
  --network=host \
  -v "$CONFIG_PATH":/home/colmenasrc/config/config.py \
  -v "$OUTPUT_PATH":/home/output_plots \
  "$DOCKER_IMAGE"

# --- Wait for simulation to start ---
"$HOME"/kiso-colmena-experiment/bin/wait-for-docker-log.sh "$DOCKER_NAME" "[Loop]"

echo "Simulation container '$DOCKER_NAME' is running and ready."

