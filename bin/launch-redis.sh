#!/bin/bash

set -e

echo "# Install Redis"
echo "---------------"

if [ ! -d $HOME/SwarmAgents ]; then
	git clone https://github.com/xcasas/SwarmAgents.git $HOME/SwarmAgents
fi
cd $HOME/SwarmAgents
git checkout colmena_backup

docker compose up -d redis
$HOME/kiso-colmena-experiment/bin/wait-for-docker-log.sh redis "Ready"