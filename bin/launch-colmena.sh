echo "# Install Colmena"
echo "-----------------"

ZENOH_ROUTER_IP="172.17.0.1"
ENDPOINT="tcp://localhost:7447"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --hardware) HARDWARE="$2"; shift ;;
    --agent) AGENT_ID="$2"; shift ;;
    --policy) POLICY="$2"; shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Validate required params
if [[ -z "$HARDWARE" || -z "$AGENT_ID" || -z "$POLICY" ]]; then
  echo "Usage: $0 --hardware <value> --agent <value> --policy <value>"
  exit 1
fi


if [ ! -d $HOME/eroots_bundle ]; then
  TOKEN_FILE="$HOME/kiso-colmena-experiment/secrets/gitlab_token.txt"
  TOKEN=$(cat "$TOKEN_FILE" | tr -d ' \n')
  REPO_URL="https://xcasas:${TOKEN}@gitlab.bsc.es/wdc/projects/colmena-group/applications/eroots_bundle.git"
        git clone "$REPO_URL" $HOME/eroots_bundle
fi
cd $HOME/eroots_bundle
git checkout swarm
cd agent

docker compose -f compose-zenoh.yaml up -d

HARDWARE="$HARDWARE" \
AGENT_ID="$AGENT_ID" \
POLICY="$POLICY" \
ZENOH_ROUTER="$ZENOH_ROUTER_IP" \
ENDPOINT="$ENDPOINT" \
docker compose -p "$AGENT_ID" -f compose.yaml up -d

BASE="$HOME/kiso-colmena-experiment/bin"

$BASE/wait-for-docker-log.sh zenoh-zenoh-router-1 "Register resource colmena_service_definitions/*" &
$BASE/wait-for-docker-log.sh "$AGENT_ID"-zenoh-client-1 "Finished getting published service definitions" &
$BASE/wait-for-docker-log.sh "$AGENT_ID"-dsm-1 "COLMENA service definition published" &
$BASE/wait-for-docker-log.sh "$AGENT_ID"-context-awareness-manager-1 "Server is ready to handle requests" &
$BASE/wait-for-docker-log.sh "$AGENT_ID"-role-selector-1 "Received service description for service:  Colmena" &
$BASE/wait-for-docker-log.sh "$AGENT_ID"-sla-manager-1 "Running and listening on port 8080 ..." &
$BASE/wait-for-docker-log.sh "$AGENT_ID"-metrics-etl-1 "Subscribed to colmena/contexts/**" &

wait
echo "All containers matched their log patterns!"
