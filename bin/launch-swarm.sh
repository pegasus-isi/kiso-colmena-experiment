#!/bin/bash

set -e

echo "# Install SWARM"
echo "---------------"

# Usage check
if [ $# -ne 4 ]; then
    echo "Usage: $0 <NUM_AGENTS> <AGENTS_PER_GROUP> <NUM_GROUPS> <CONFIG_PATH>"
    exit 1
fi

NUM_AGENTS=$1
AGENTS_PER_GROUP=$2
NUM_GROUPS=$3
CONFIG_PATH=$4

AGENT_NUM=$AGENT_NUM
AGENT_AREA=$AGENT_AREA
REDIS_IP=andes

# Clone repository if it doesn’t exist
if [ ! -d "$HOME/SwarmAgents" ]; then
    git clone https://github.com/xcasas/SwarmAgents.git "$HOME/SwarmAgents"
fi

cd "$HOME/SwarmAgents"
git checkout colmena_backup

python3 -m pip install -r requirements.txt

python3 -m generate_configs "$NUM_AGENTS" "$AGENTS_PER_GROUP" \
    config_swarm_multi.yml configs mesh "$REDIS_IP" 100 \
    --agents-per-host 1 --groups "$NUM_GROUPS" \
    --agent-hosts-file "$CONFIG_PATH/host_file"

AGENTS_PER_AREA=3
GLOBAL_AGENT_NUM=$(( (AGENT_AREA - 1) * AGENTS_PER_AREA + AGENT_NUM ))

CONFIG_FILE="config_swarm_multi_${GLOBAL_AGENT_NUM}.yml"
LOGFILE="$HOME/SwarmAgents/swarm-multi/agent-${GLOBAL_AGENT_NUM}.log"

python3 -u "${HOME}/SwarmAgents/main.py" "$GLOBAL_AGENT_NUM" \
    --config "$HOME/SwarmAgents/configs/$CONFIG_FILE" \
    --agent-type colmena \
    --debug &


while [ ! -f "$LOGFILE" ]; do
    sleep 0.2
done

$HOME/kiso-colmena-experiment/bin/wait-for-text.sh "$LOGFILE" "Starting colmena agent"
