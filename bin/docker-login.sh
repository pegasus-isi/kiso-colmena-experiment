#!/bin/bash

set -ex

echo "# Docker login"
echo "--------------------"

DOCKER_USER="$1"

# --- Validate inputs ---
if [ -z "$DOCKER_USER" ] ; then
  echo "Usage: $0 <dockerhub-username>"
  exit 1
fi


sudo -n docker login \
  --username "$DOCKER_USER" \
  --password-stdin \
  < ~/kiso-colmena-experiment/secrets/docker_token.txt > docker.txt 2>&1