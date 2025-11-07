#!/bin/bash

set -e

echo "# Execute Docker container with random RAM usage"
echo "--------------------------------------------------"


docker run -d --name random --network host ubuntu:latest bash -c '
  set -e
  apt update -qq
  apt install -y -qq stress

  RAM_MB=$((RANDOM % 5000))
  echo "Allocating ${RAM_MB} MB of RAM"

  stress --vm 1 --vm-bytes "${RAM_MB}M" --vm-hang 0'

$HOME/kiso-colmena-experiment/bin/wait-for-docker-log.sh random "Allocating"
