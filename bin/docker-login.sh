#!/bin/bash

set -e

echo "# Docker login"
echo "--------------------"

sudo usermod -aG docker $USER
newgrp docker

DOCKER_USER="$1"

# --- Validate inputs ---
if [ -z "$DOCKER_USER" ] ; then
  echo "Usage: $0 <dockerhub-username>"
  exit 1
fi


docker login \
  --username "$DOCKER_USER" \
  --password-stdin \
  < ~/kiso-colmena-experiment/secrets/docker_token.txt