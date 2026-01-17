#!/bin/bash

CONFIG_PATH="$1"
read -r DOCKER_USER < "$HOME/kiso-colmena-experiment/secrets/docker_username.txt"

if [ -z "$CONFIG_PATH" ]; then
  echo "Usage: $0 <path-to-build-context-folder>"
  echo "Example: $0 ~/kiso-colmena-experiment/example_config"
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
