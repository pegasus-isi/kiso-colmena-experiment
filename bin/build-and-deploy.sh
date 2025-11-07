#!/bin/bash

set -e

echo "# Build and deploy use case"
echo "--------------------"

DOCKER_USER="xaviercasasbsc"
SERVICE_MODULE="mpc_kpi_driven"
SERVICE_NAME="AgentControl"
AGENT_ID="agent_1_1"

sudo rm -rf $HOME/eroots_bundle/eroots/mpc_kpi_driven/
docker run --rm \
  -u "$(id -u)":"$(id -g)" \
  -v $HOME/eroots_bundle/eroots:/app \
  "$DOCKER_USER"/programming-model:latest \
  --service_path="/app/${SERVICE_MODULE}.py"


docker run \
	-v /var/run/docker.sock:/var/run/docker.sock \
        -v $HOME/eroots_bundle/eroots/"$SERVICE_MODULE"/build:/app \
        -v $HOME/eroots_bundle/agent/peer/zenoh_config.json5:/colmena/deployment/zenoh_config.json5:ro \
        --network=host \
        "$DOCKER_USER"/deployment-tool:latest \
        --build_path=/app --platform=linux/amd64 --user="$DOCKER_USER" \
        --skip_build

$HOME/kiso-colmena-experiment/bin/wait-for-docker-log.sh "$AGENT_ID"-role-selector-1 "$SERVICE_NAME"