#!/bin/bash

echo "# Docker login"
echo "--------------------"

USERNAME_FILE="secrets/docker_username.txt"
TOKEN_FILE="secrets/docker_token.txt"

# --- Validate secrets ---
if [[ ! -f "$USERNAME_FILE" ]]; then
  echo "Error: missing $USERNAME_FILE"
  exit 1
fi

if [[ ! -f "$TOKEN_FILE" ]]; then
  echo "Error: missing $TOKEN_FILE"
  exit 1
fi

read -r DOCKER_USER < "$USERNAME_FILE"

# --- Idempotent check ---
if docker system info 2>/dev/null | grep -q "Username: $DOCKER_USER"; then
  echo "Already logged into Docker as $DOCKER_USER"
else
# --- Login ---
  docker login \
    --username "$DOCKER_USER" \
    --password-stdin \
    < "$TOKEN_FILE" > docker.txt 2>&1

  echo "Docker login successful"
fi
