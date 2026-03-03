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
REDIS_IP=andes

# --- Read secrets if needed ---
if [[ -z "$AGENT_AREA" && -f secrets/agent_area ]]; then
  read -r AGENT_AREA < secrets/agent_area
fi

if [[ -z "$AGENT_NUM" && -f secrets/agent_num ]]; then
  read -r AGENT_NUM < secrets/agent_num
fi

# Only download if directory doesn't exist
if [ ! -d "$HOME/SwarmAgents" ]; then
    mkdir -p "$HOME/SwarmAgents"
    curl -L https://github.com/xcasas/SwarmAgents/archive/refs/heads/colmena_backup.zip \
        -o /tmp/SwarmAgents.zip

    unzip -q /tmp/SwarmAgents.zip -d /tmp
    mv /tmp/SwarmAgents-colmena_backup/* "$HOME/SwarmAgents"
    rm -rf /tmp/SwarmAgents.zip /tmp/SwarmAgents-colmena_backup
fi

cd "$HOME/SwarmAgents"

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
