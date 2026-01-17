#!/usr/bin/env bash
set -e

# --- Read secrets if needed ---
if [[ -z "$AGENT_AREA" && -f secrets/agent_area ]]; then
  read -r AGENT_AREA < secrets/agent_area
fi

if [[ -z "$AGENT_NUM" && -f secrets/agent_num ]]; then
  read -r AGENT_NUM < secrets/agent_num
fi

# --- Validate required environment variables ---
if [[ -z "$AGENT_NUM" || -z "$AGENT_AREA" ]]; then
  echo "Error: AGENT_NUM and AGENT_AREA environment variables are required."
  echo "Example: export AGENT_NUM=1; export AGENT_AREA=3"
  exit 1
fi

docker logs agent_${AGENT_NUM}_${AGENT_AREA}-sla-manager-1 > $HOME/logs.txt 2>&1

perl -ne 'if (/^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z).*?Value:\s*([0-9]+(?:\.[0-9]+)?)/) {
    $ts=$1; $val=$2;
    chomp($epoch=`date -d "$ts" +"%s%3N"`);
    print "$epoch $val\n";
}' $HOME/logs.txt > $HOME/logs_parsed.txt