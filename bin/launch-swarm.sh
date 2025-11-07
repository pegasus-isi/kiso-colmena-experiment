#!/bin/bash

set -e

echo "# Install SWARM"
echo "---------------"

# --- Read AGENT_NUM from input ---
if [ -z "$1" ]; then
    echo "Usage: $0 <AGENT_NUM>"
    exit 1
fi

AGENT_NUM="$1"

NUM_AGENTS=18
AGENTS_PER_GROUP=3
REDIS_IP=localhost
NUM_GROUPS=6

CONFIG_FILE="config_swarm_multi_${AGENT_NUM}.yml"

if [ ! -d "$HOME/SwarmAgents" ]; then
    git clone https://github.com/xcasas/SwarmAgents.git "$HOME/SwarmAgents"
fi

cd "$HOME/SwarmAgents"
git checkout colmena-new

python3 -m pip install -r requirements.txt

python3 -m generate_configs "$NUM_AGENTS" "$AGENTS_PER_GROUP" \
    config_swarm_multi.yml configs mesh "$REDIS_IP" 100 \
    --agents-per-host 1 --groups "$NUM_GROUPS"

python3 main.py "$AGENT_NUM" \
    --config "configs/$CONFIG_FILE" \
    --agent-type colmena --debug &

tail -f "$HOME/SwarmAgents/swarm-multi/agent-${AGENT_NUM}.log" \
    | "$HOME/kiso-colmena-experiment/bin/wait-for-text.sh" "Starting colmena agent"

