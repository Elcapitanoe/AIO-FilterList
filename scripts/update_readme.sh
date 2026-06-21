#!/bin/bash

CONFIG_FILE="config/sources.txt"
README_FILE="README.md"
OUTPUT_DIR="filters"

> "$README_FILE"

{
    echo "<div align=\"center\">"
    echo "  <h1>AIO Filter List</h1>"
    echo "  <p><em>Automated Aggregation and Optimization Tool for Community Filter Lists</em></p>"
    echo "</div>"
    echo ""
    echo "<br />"
    echo ""
    echo "## Overview"
    echo ""
    echo "Before proceeding, please note: **I do not claim ownership of the filter rules in this repository.** This project does not maintain the original blocklists. It serves strictly as an automated aggregation pipeline."
    echo ""
    echo "It routinely fetches, sanitizes, and merges several highly respected community filter lists into a single, optimized file for seamless integration. All credit belongs entirely to the original authors and communities who maintain these upstream filters. Please support them if you find their work valuable."
    echo ""
    echo "## Direct Access"
    echo ""
    echo "\`\`\`"
    echo "https://hosts.domi.my.id/AIO_Filter_List.txt"
    echo "\`\`\`"
    echo ""
    echo "## Upstream Sources and Mirrors"
    echo ""
    echo "This repository builds upon the following upstream projects. Below is the active routing table for all pulled sources, complete with global CDN mirrors."
    echo ""
    echo "| Filter Name | Upstream | Main Mirror | jsDelivr CDN | Edge CDN | Last Updated |"
    echo "| :--- | :---: | :---: | :---: | :---: | :---: |"
} >> "$README_FILE"

sort -t '|' -k3 -f "$CONFIG_FILE" | while IFS='|' read -r filename url title; do
    if [[ -z "$filename" ]]; then
        continue
    fi
    
    filename=$(echo "$filename" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
    url=$(echo "$url" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
    title=$(echo "$title" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
    
    FILE_PATH="$OUTPUT_DIR/$filename"
    
    if [[ -n $(git status --porcelain "$FILE_PATH" 2>/dev/null) ]]; then
        LAST_UPDATED=$(TZ='Asia/Jakarta' date +'%Y-%m-%d %H:%M:%S')
    else
        LAST_UPDATED=$(git log -1 --format="%cd" --date=format:'%Y-%m-%d %H:%M:%S' -- "$FILE_PATH" 2>/dev/null)
        if [[ -z "$LAST_UPDATED" ]]; then
            LAST_UPDATED=$(TZ='Asia/Jakarta' date +'%Y-%m-%d %H:%M:%S')
        fi
    fi
    
    MIRROR_1="https://hosts.domi.my.id/filters/$filename"
    MIRROR_2="https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/$filename"
    MIRROR_3="https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/$filename"
    
    echo "| **$title** | [Source]($url) | [hosts.domi]($MIRROR_1) | [jsDelivr]($MIRROR_2) | [cdn.domi]($MIRROR_3) | \`$LAST_UPDATED\` |" >> "$README_FILE"
done

{
    echo ""
    echo "## Architecture and Workflow"
    echo ""
    echo "A GitHub Actions workflow executes daily to synchronize upstream sources. The automated pipeline performs the following operations:"
    echo ""
    echo "1. **Data Ingestion:** Pulls raw text files from upstream URLs."
    echo "2. **Sanitization:** Strips original metadata headers to prevent parser conflicts."
    echo "3. **Optimization:** Deduplicates rules to maintain a lightweight footprint."
    echo "4. **Compilation:** Merges the processed data into the root \`AIO_Filter_List.txt\` artifact."
} >> "$README_FILE"
