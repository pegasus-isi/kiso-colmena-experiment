#!/bin/bash
set -euo pipefail

LOGFILE=${1:?usage: $0 LOGFILE [PATTERN]}
PATTERN=${2:-"Starting colmena agent"}

# Start at end of file; follow new lines. Print everything, exit on first match.
# When awk exits, the pipe closes and tail stops, so the SSH command ends.
tail -n0 -F -- "$LOGFILE" | awk -v pat="$PATTERN" '
  { print; fflush(); }
  index($0, pat) { exit 0 }
'

