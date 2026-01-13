#!/usr/bin/env bash
set -e

AGENT_NUM="${AGENT_NUM:?Missing AGENT_NUM}"
AGENT_AREA="${AGENT_AREA:?Missing AGENT_AREA}"

docker logs agent_${AGENT_NUM}_${AGENT_AREA}-sla-manager-1 > $HOME/logs.txt 2>&1

perl -ne 'if (/^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z).*?Value:\s*([0-9]+(?:\.[0-9]+)?)/) {
    $ts=$1; $val=$2;
    chomp($epoch=`date -d "$ts" +"%s%3N"`);
    print "$epoch $val\n";
}' $HOME/logs.txt > $HOME/logs_parsed.txt