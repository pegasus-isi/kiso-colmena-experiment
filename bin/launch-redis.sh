#!/bin/bash

set -e

echo "# Install Redis"
echo "---------------"

if [ ! -d /home/kiso/SwarmAgents ]; then
	git clone https://github.com/xcasas/SwarmAgents.git /home/kiso/SwarmAgents
fi
cd /home/kiso/SwarmAgents
git checkout colmena-new

docker compose up -d redis
/home/kiso/kiso-colmena-experiment/bin/wait-for-docker-log.sh redis "Ready"