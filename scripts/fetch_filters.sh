#!/bin/bash

set -eo pipefail

CONFIG_FILE="config/sources.txt"
OUTPUT_DIR="filters"

mkdir -p "$OUTPUT_DIR"

echo "Initiating parallel upstream synchronization..."

PIDS=()

while IFS='|' read -r filename url title; do
    filename=$(echo "$filename" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
    url=$(echo "$url" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
    title=$(echo "$title" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')

    if [[ -z "$filename" || "$filename" == \#* ]]; then
        continue
    fi
    
    (
        echo "Fetching: $title"
        if ! curl -sSL --fail --retry 3 --connect-timeout 15 --max-time 30 "$url" -o "$OUTPUT_DIR/$filename"; then
            echo "[ERROR] Pipeline failed to fetch $title from $url" >&2
            exit 1
        fi
    ) &
    PIDS+=($!)
done < "$CONFIG_FILE"

for pid in "${PIDS[@]}"; do
    wait "$pid"
done

echo "Filter synchronization completely verified."
