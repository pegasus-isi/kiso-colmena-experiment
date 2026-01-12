#!/usr/bin/env bash
set -e
# Container name (default: andes)
CONTAINER="${1:-andes}"

# Grab docker logs containing "Success"
LOG_OUTPUT=$(sudo -n docker logs -t "$CONTAINER" 2>&1 | grep "Success")

if [[ -z "$LOG_OUTPUT" ]]; then
    echo "No 'Success' entries found in logs."
    exit 1
fi

# Extract all ISO-8601 timestamps with fractional seconds ending in Z
TIMESTAMPS=($(echo "$LOG_OUTPUT" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]+Z'))

if [[ ${#TIMESTAMPS[@]} -eq 0 ]]; then
    echo "No timestamps found in matching log lines."
    exit 1
fi

# Get the last timestamp
LAST_TS="${TIMESTAMPS[-1]}"

# Convert to Unix epoch (requires GNU date)
EPOCH_TIME=$(date -d "${LAST_TS}" +"%s")

if [[ -z "$EPOCH_TIME" ]]; then
    echo "Failed to convert timestamp."
    exit 1
fi

# Save to file
echo "$EPOCH_TIME" > $HOME/perturbation_time.txt

echo "Saved timestamp: $EPOCH_TIME"
