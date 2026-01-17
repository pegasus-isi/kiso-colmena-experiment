#!/bin/bash

set -e

echo "# Install Redis"
echo "---------------"

# Only download if directory doesn't exist
if [ ! -d "$HOME/SwarmAgents" ]; then
    mkdir -p "$HOME/SwarmAgents"
    curl -L https://github.com/xcasas/SwarmAgents/archive/refs/heads/colmena_backup.zip \
        -o /tmp/SwarmAgents.zip

    unzip -q /tmp/SwarmAgents.zip -d /tmp
    mv /tmp/SwarmAgents-colmena_backup/* "$HOME/SwarmAgents"
    rm -rf /tmp/SwarmAgents.zip /tmp/SwarmAgents-colmena_backup
fi

$HOME/kiso-colmena-experiment/bin/docker-login.sh

cd $HOME/SwarmAgents

docker compose up -d redis
$HOME/kiso-colmena-experiment/bin/wait-for-docker-log.sh redis "Ready"