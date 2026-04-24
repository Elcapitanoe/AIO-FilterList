#!/bin/bash

CONFIG_FILE="config/sources.txt"
README_FILE="README.md"
OUTPUT_DIR="filters"
LAST_SYNCED=$(date -u +'%Y-%m-%d')

> "$README_FILE"

echo "<br />" >> "$README_FILE"
echo "<h1 align=\"center\">AIO Filter List</h1>" >> "$README_FILE"
echo "<br />" >> "$README_FILE"
echo "Before you dive in, I want to make it absolutely clear that I do not claim ownership or take any credit for the filter rules found in this repository. I did not write them, and I do not maintain the original blocklists." >> "$README_FILE"
echo "" >> "$README_FILE"
echo "This project is simply an automated aggregation tool. It routinely fetches, cleans, and merges several highly respected community filter lists into a single file for my own convenience, and I am making it public in case others find it useful." >> "$README_FILE"
echo "" >> "$README_FILE"
echo "All credit belongs entirely to the original authors and the communities that spend their time keeping these web filters updated. If you appreciate the ad-blocking and privacy protection provided here, please support the upstream maintainers." >> "$README_FILE"
echo "" >> "$README_FILE"
echo "### Direct Access" >> "$README_FILE"
echo '```' >> "$README_FILE"
echo "https://hosts.domi.my.id/AIO_Filter_List.txt" >> "$README_FILE"
echo '```' >> "$README_FILE"
echo "" >> "$README_FILE"
echo "### Upstream Sources" >> "$README_FILE"
echo "" >> "$README_FILE"
echo "This repository is built on the hard work of the following projects. Here is the exact list of sources pulled during the automation process:" >> "$README_FILE"
echo "" >> "$README_FILE"
echo "| Filter Name | Original Source | Mirror Link | Last Synced |" >> "$README_FILE"
echo "|---|---|---|---|" >> "$README_FILE"

sort -t '|' -k3 -f "$CONFIG_FILE" | while IFS='|' read -r filename url title; do
    if [[ -z "$filename" ]]; then
        continue
    fi
    
    filename=$(echo "$filename" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
    url=$(echo "$url" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
    title=$(echo "$title" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
    
    MIRROR_LINK="https://hosts.domi.my.id/filters/$filename"
    echo "| $title | [Original]($url) | [Mirror]($MIRROR_LINK) | $LAST_SYNCED |" >> "$README_FILE"
done

echo "" >> "$README_FILE"
echo "### How It Works" >> "$README_FILE"
echo "" >> "$README_FILE"
echo "A GitHub Action runs automatically every day to pull the latest raw text files from the URLs listed above. The script strips out the original metadata headers to prevent parsing errors, removes duplicate rules to keep the file lightweight, and compiles everything into the \`AIO_Filter_List.txt\` file located in the root directory." >> "$README_FILE"
