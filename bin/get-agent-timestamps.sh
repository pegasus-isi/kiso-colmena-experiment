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

# -------------------------------------------------------
# Ensure timestamps folder exists (remove & recreate if already exists)
# -------------------------------------------------------
TIMESTAMP_DIR="$HOME/timestamps"

if [[ -d "$TIMESTAMP_DIR" ]]; then
    echo "Removing existing timestamps folder..."
    rm -rf "$TIMESTAMP_DIR"
fi

echo "Creating timestamps folder..."
mkdir -p "$TIMESTAMP_DIR"


AGENT_ID="agent_${AGENT_NUM}_${AGENT_AREA}"
ROLE_NAME="${ROLE_NAME:-Distributed_MPC}"
OUTPUT_FILE="$HOME/timestamps/timestamps_$AGENT_ID.json"

echo "Running on agent: $AGENT_ID"
echo "Checking if this agent became leader..."
echo

# -------------------------------------------------------
# Check if this agent is leader for any role
# -------------------------------------------------------
AGENTS_PER_AREA=10
GLOBAL_AGENT_NUM=$(( (AGENT_AREA - 1) * AGENTS_PER_AREA + AGENT_NUM ))

MY_RAW_LINE=$(cd $HOME/SwarmAgents && python3 dump_db.py --key role --host andes \
  | grep "\"leader_id\": $GLOBAL_AGENT_NUM" \
  | head -n1 || true)

if [[ -z "$MY_RAW_LINE" ]]; then
  echo "This agent is NOT a leader for any role. No JSON will be saved."
  exit 0
fi

# Extract JSON payload after the first colon
JSON_PART="${MY_RAW_LINE#*: }"

# Extract leader_id (should match AGENT_NUM)
MY_AREA_LEADER_ID=$(echo "$JSON_PART" | grep -oE '"leader_id": [0-9]+' | awk '{print $3}')

echo "This agent *IS* a leader (leader_id=$MY_AREA_LEADER_ID)"
echo

# -------------------------------------------------------
# Container name for timestamp extraction
# -------------------------------------------------------
CONTAINER="${AGENT_ID}-role-selector-1"

echo "Using container: $CONTAINER"
echo

# -------------------------------------------------------
# Timestamp extractor
# -------------------------------------------------------
extract_ts() {
  local container="$1"
  local pattern="$2"

  local line
  line=$(docker logs --tail 4000 "$container" 2>&1 | grep "$pattern" | head -n 1 || true)

  if [[ -z "$line" ]]; then
    echo ""
    return
  fi

  # Extract Go timestamp
  local ts
  ts=$(echo "$line" | grep -oE '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?')

  if [[ -z "$ts" ]]; then
    echo ""
    return
  fi

  date -d "$ts" +"%s.%N" 2>/dev/null
}

# -------------------------------------------------------
# Extract timestamps
# -------------------------------------------------------
echo "Extracting timestamps..."
t_consensus=$(extract_ts "$CONTAINER" "Decision request sent at")
t_role=$(extract_ts "$CONTAINER" "Decided to run role: $ROLE_NAME")
t_kpi=$(extract_ts "$CONTAINER" "KPI Met for role $ROLE_NAME")

# -------------------------------------------------------
# Only write JSON if at least one timestamp is found
# -------------------------------------------------------
if [[ -n "$t_consensus" || -n "$t_role" || -n "$t_kpi" ]]; then
  cat <<EOF > "$OUTPUT_FILE"
[
  {
    "leader_id": $AGENT_NUM,
    "t_consensus": ${t_consensus:-null},
    "t_role": ${t_role:-null},
    "t_kpi": ${t_kpi:-null}
  }
]
EOF
  echo
  echo "Saved → $OUTPUT_FILE"
else
  echo "No timestamps found. No JSON file created."
fi

