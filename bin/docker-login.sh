#!/bin/bash

set -e

echo "# Docker login"
echo "--------------------"

DOCKER_USER="$1"

# --- Validate inputs ---
if [ -z "$DOCKER_USER" ] ; then
  echo "Usage: $0 <dockerhub-username>"
  exit 1
fi


cat ~/kiso-colmena-experiment/secrets/dockerhub_login.txt | docker login --username ${DOCKER_USER} --password-stdin