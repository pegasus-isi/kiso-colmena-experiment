#!/bin/bash

set -e

echo "# Install Simulation"
echo "--------------------"

if [ ! -d $HOME/eroots_bundle ]; then
  TOKEN_FILE="$HOME/kiso-colmena-experiment/secrets/gitlab_token.txt"
  TOKEN=$(cat "$TOKEN_FILE" | tr -d ' \n')
  REPO_URL="https://xcasas:${TOKEN}@gitlab.bsc.es/wdc/projects/colmena-group/applications/eroots_bundle.git"
	git clone "$REPO_URL" $HOME/eroots_bundle
fi
cd $HOME/eroots_bundle
git checkout swarm

DIR="$HOME/eroots_bundle"
docker run -d --name andes --network=host -v "$DIR"/eroots/config.py:/home/colmenasrc/config/config.py -v "$DIR"/eroots/output_plots:/home/output_plots xaviercasasbsc/andes_src
$HOME/kiso-colmena-experiment/bin/wait-for-docker-log.sh andes "[Loop]"
