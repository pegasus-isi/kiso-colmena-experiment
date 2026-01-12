#!/bin/bash

set -ex

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

# --- Remove any existing container ---
if sudo -n docker ps -a --format '{{.Names}}' | grep -q "^${DOCKER_NAME}\$"; then
  echo "Removing existing container: $DOCKER_NAME"
  sudo -n docker rm -f "$DOCKER_NAME"
fi

# --- Run simulation container ---
echo "Starting Docker container: $DOCKER_NAME"
sudo -n docker run -d \
  --name "$DOCKER_NAME" \
  --network=host \
  -v "$CONFIG_PATH":/home/colmenasrc/config/config.py \
  -v "$OUTPUT_PATH":/home/output_plots \
  "$DOCKER_IMAGE" > simulation.txt 2>&1

# --- Wait for simulation to start ---
"$HOME"/kiso-colmena-experiment/bin/wait-for-docker-log.sh "$DOCKER_NAME" "[Loop]"

echo "Simulation container '$DOCKER_NAME' is running and ready."

