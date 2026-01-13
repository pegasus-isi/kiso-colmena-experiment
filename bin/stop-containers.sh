#!/bin/bash
set -e

# List all container IDs
containers=$(docker ps -q -a)

if [ -z "$containers" ]; then
    echo "No running containers."
    exit 0
fi

echo "Stopping all running containers..."
docker stop $containers
docker rm $containers

echo "All containers stopped and removed."
