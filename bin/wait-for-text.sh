#!/bin/bash

TEXT_TO_SEARCH="$1"

while IFS= read -r line; do
    echo $line | grep "$TEXT_TO_SEARCH" > /dev/null 2>&1
    EC=$?
    if [[ $EC -eq 0 ]]; then
        echo "Found '$TEXT_TO_SEARCH' in '$line'"
        exit 0
    fi
done

exit 1
