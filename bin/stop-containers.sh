#!/bin/bash
set -e

# List all running container IDs
containers=$(docker ps -q)

if [ -z "$containers" ]; then
    echo "No running containers."
    exit 0
fi

echo "Stopping all running containers..."
docker stop $containers
docker rm $containers

echo "All containers stopped and removed."
