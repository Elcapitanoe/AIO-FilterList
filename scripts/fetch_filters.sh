#!/bin/bash

CONFIG_FILE="config/sources.txt"
OUTPUT_DIR="filters"

mkdir -p "$OUTPUT_DIR"

while read -r filename url; do
    if [[ -z "$filename" || "$filename" == \#* ]]; then
        continue
    fi
    
    echo "Fetching $filename from upstream..."
    curl -sSL "$url" -o "$OUTPUT_DIR/$filename"
done < "$CONFIG_FILE"

echo "Filter synchronization complete."
