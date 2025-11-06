#!/bin/bash

CONTAINER="$1"
SEARCH="$2"

# Start docker logs in background and capture its PID
docker logs -f "$CONTAINER" 2>&1 | while read -r line; do
    echo "$line"

    if [[ "$line" == *"$SEARCH"* ]]; then
        echo "Matched: $line"
        # Kill docker logs -f (parent of this while-loop pipeline)
        pkill -P $$ docker 2>/dev/null
        exit 0
    fi
done

