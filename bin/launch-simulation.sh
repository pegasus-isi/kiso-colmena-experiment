#!/bin/bash

set -e

echo "# Install Simulation"
echo "--------------------"

if [ ! -d /home/kiso/eroots_bundle ]; then
  TOKEN_FILE="/home/kiso/kiso-colmena-experiment/secrets/gitlab_token.txt"
  TOKEN=$(cat "$TOKEN_FILE" | tr -d ' \n')
  REPO_URL="https://xcasas:${TOKEN}@gitlab.bsc.es/wdc/projects/colmena-group/applications/eroots_bundle.git"
	git clone "$REPO_URL" /home/kiso/eroots_bundle
fi
cd /home/kiso/eroots_bundle
git checkout swarm

DIR="/home/kiso/eroots_bundle"
docker run -d --name andes -p 5000:5000 -v "$DIR"/eroots/config.py:/home/colmenasrc/config/config.py -v "$DIR"/eroots/output_plots:/home/output_plots xaviercasasbsc/andes_src
/home/kiso/kiso-colmena-experiment/bin/wait-for-docker-log.sh andes "[Loop]"
