#!/bin/bash
set -e

CONFIG_PATH="$1"
DOCKER_USER="$2"

if [ -z "$CONFIG_PATH" ] || [ -z "$DOCKER_USER" ]; then
  echo "Usage: $0 <path-to-build-context-folder> <dockerhub-username>"
  echo "Example: $0 ~/kiso-colmena-experiment/example_config xaviercasasbsc"
  exit 1
fi

echo "Using build context: $CONFIG_PATH"
echo "Using Docker Hub user: $DOCKER_USER"

cd "$CONFIG_PATH/docker"

for ROLE in monitoringrole distributed_mpc simulationmanager; do
  echo "Building $ROLE..."

  docker build \
    -t "${DOCKER_USER}/${ROLE}:0.1" \
    -f "Dockerfile.${ROLE}" \
    ../

  docker push "${DOCKER_USER}/${ROLE}:0.1"
done

echo "Built and pushed all images using context: $CONFIG_PATH"
