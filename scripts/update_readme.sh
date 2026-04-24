#!/bin/bash

CONFIG_FILE="config/sources.txt"
README_FILE="README.md"
OUTPUT_DIR="filters"

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
echo '```text' >> "$README_FILE"
echo "https://hosts.domi.my.id/AIO_Filter_List.txt" >> "$README_FILE"
echo '```' >> "$README_FILE"
echo "" >> "$README_FILE"
echo "### Upstream Sources" >> "$README_FILE"
echo "" >> "$README_FILE"
echo "This repository is built on the hard work of the following projects. Here is the exact list of sources pulled during the automation process:" >> "$README_FILE"
echo "" >> "$README_FILE"
echo "| Filter Name | Original Source | Mirror Link | Last Update |" >> "$README_FILE"
echo "|---|---|---|---|" >> "$README_FILE"

sort -t '|' -k3 -f "$CONFIG_FILE" | while IFS='|' read -r filename url title; do
    if [[ -z "$filename" ]]; then
        continue
    fi
    
    FILE_PATH="$OUTPUT_DIR/$filename"
    LAST_UPDATE="Unknown"
    
    if [[ -f "$FILE_PATH" ]]; then
        EXTRACTED=$(grep -m 1 -iE '^[!#] *(TimeUpdated|Updated|Last Update|Version|Last modified):' "$FILE_PATH" | tr -d '\r' | cut -d':' -f2- | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        if [[ -n "$EXTRACTED" ]]; then
            CLEAN_DATE=$(echo "$EXTRACTED" | sed -E 's/[\.\+]+$//g' | sed 's/T/ /g')
            if [[ "$CLEAN_DATE" =~ ^[0-9]{12}$ ]]; then
                CLEAN_DATE=$(echo "$CLEAN_DATE" | sed -E 's/([0-9]{4})([0-9]{2})([0-9]{2}).*/\1-\2-\3/')
            fi
            PARSED_DATE=$(date -u -d "$CLEAN_DATE" +'%Y-%m-%d' 2>/dev/null)
            if [[ -n "$PARSED_DATE" ]]; then
                LAST_UPDATE="$PARSED_DATE"
            else
                REGEX_DATE=$(echo "$CLEAN_DATE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n 1)
                if [[ -n "$REGEX_DATE" ]]; then
                    LAST_UPDATE="$REGEX_DATE"
                else
                    LAST_UPDATE=$(date -u +'%Y-%m-%d')
                fi
            fi
        else
            LAST_UPDATE=$(date -u +'%Y-%m-%d')
        fi
    fi
    
    MIRROR_LINK="https://hosts.domi.my.id/filters/$filename"
    echo "| $title | [Original]($url) | [Mirror]($MIRROR_LINK) | $LAST_UPDATE |" >> "$README_FILE"
done

echo "" >> "$README_FILE"
echo "### How It Works" >> "$README_FILE"
echo "" >> "$README_FILE"
echo "A GitHub Action runs automatically every day to pull the latest raw text files from the URLs listed above. The script strips out the original metadata headers to prevent parsing errors, removes duplicate rules to keep the file lightweight, and compiles everything into the \`AIO_Filter_List.txt\` file located in the root directory." >> "$README_FILE"
