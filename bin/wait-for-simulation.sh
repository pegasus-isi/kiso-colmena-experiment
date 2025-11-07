#!/bin/bash

set -e

echo "# Wait for simulation to end"
echo "--------------------"

"$HOME"/kiso-colmena-experiment/bin/wait-for-docker-log.sh andes "[Main] Simulation completed succesfully."

echo "Simulation container has finished."