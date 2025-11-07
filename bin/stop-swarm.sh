#!/bin/bash
set -e

echo "Stopping Swarm processes (main.py)..."

# Kill all processes with 'main.py' in their command line
pkill -f 'main.py' || {
    echo "No processes named 'main.py' were running."
exit 0
}

echo "All 'main.py' processes stopped."
