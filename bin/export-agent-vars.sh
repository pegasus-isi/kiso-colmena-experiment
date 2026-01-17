#!/usr/bin/env bash

set -e

# Extract AGENT_AREA from hostname (pattern: -m<digits>-)
AGENT_AREA=$(hostname | sed -n 's/.*-m\([0-9]\+\)-.*/\1/p')

# Extract AGENT_NUM from hostname (pattern: -n<digits> at end)
AGENT_NUM=$(hostname | sed -n 's/.*-n\([0-9]\+\)$/\1/p')

# Apply special rule: if AGENT_AREA == 4, set both to 0
if [[ "${AGENT_AREA:-}" == "4" ]]; then
  AGENT_AREA=0
  AGENT_NUM=0
fi

# Write values to files
echo "$AGENT_AREA" > secrets/agent_area
echo "$AGENT_NUM"  > secrets/agent_num
