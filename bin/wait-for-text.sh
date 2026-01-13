#!/bin/bash

LOGFILE=${1:?usage: $0 LOGFILE [PATTERN]}
PATTERN=${2:-"Starting colmena agent"}

tail -n +1 -F -- "$LOGFILE" | awk -v pat="$PATTERN" '
  { print; fflush(); }
  index($0, pat) { exit 0 }
'
