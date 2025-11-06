#!/bin/bash

set -e

echo "# Install SWARM"
echo "---------------"

NUM_AGENTS=18
AGENTS_PER_GROUP=3
REDIS_IP=localhost
NUM_GROUPS=6
AGENT_NUM=1
CONFIG_FILE="config_swarm_multi_1.yml"

if [ ! -d ~/SwarmAgents ]; then
        git clone https://github.com/xcasas/SwarmAgents.git ~/SwarmAgents
fi
cd ~/SwarmAgents
git checkout colmena-new

python3 -m pip install -r requirements.txt
python3 -m generate_configs "$NUM_AGENTS" "$AGENTS_PER_GROUP" config_swarm_multi.yml configs mesh "$REDIS_IP" 100 --agents-per-host 1 --groups "$NUM_GROUPS"
python3 main.py "$AGENT_NUM" --config configs/"$CONFIG_FILE" --agent-type colmena --debug &

tail -f ~/SwarmAgents/swarm-multi/agent-"$AGENT_NUM".log | ~/kiso-colmena-experiment/bin/wait-for-text.sh "Starting colmena agent"
