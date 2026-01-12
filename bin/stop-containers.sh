#!/bin/bash
set -e

# List all container IDs
containers=$(sudo -n docker ps -q -a)

if [ -z "$containers" ]; then
    echo "No running containers."
    exit 0
fi

echo "Stopping all running containers..."
sudo -n docker stop $containers
sudo -n docker rm $containers

echo "All containers stopped and removed."
