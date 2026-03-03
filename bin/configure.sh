#!/bin/bash

echo "# Configure"
echo "---------------------------"

sudo usermod -a -G docker kiso
sudo apt update
sudo apt install -y unzip
sudo sed -i '/^# Kiso: End/,$!b; /^# Kiso: End/{n; :a; $!{N; ba}; d}' /etc/hosts
sudo tee -a /etc/hosts < secrets/hosts
bin/export-agent-vars.sh
bin/zenoh-config.sh example_config/agent/zenoh-router/zenohd-config.json5
