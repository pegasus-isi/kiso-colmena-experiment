#!/bin/bash
set -ex

TARGET_HOST="fabric-sWASH-m4-n1"
ALIAS="andes"
HOSTS_FILE="/etc/hosts"

# Check if the alias is already present
if grep -qw "$ALIAS" "$HOSTS_FILE"; then
    echo "$ALIAS already exists in $HOSTS_FILE"
    exit 0
fi

# Find the line containing the target hostname
LINE=$(grep -w "$TARGET_HOST" "$HOSTS_FILE")

if [ -z "$LINE" ]; then
    echo "Error: $TARGET_HOST not found in $HOSTS_FILE"
    exit 1
fi

# Append the alias to the end of the line
sudo -n sed -i "s/\b$TARGET_HOST\b/& $ALIAS/" "$HOSTS_FILE" > andes.txt 2>&1

echo "Alias $ALIAS added to $TARGET_HOST in $HOSTS_FILE"
