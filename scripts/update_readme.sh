#!/bin/bash

CONFIG_FILE="config/sources.txt"
README_FILE="README.md"
OUTPUT_DIR="filters"
TEMP_MD="temp_table.md"

echo "Generating dynamic table for README.md..."

echo "| Filter Name | Original Source | Mirror Link | Last Update |" > "$TEMP_MD"
echo "|---|---|---|---|" >> "$TEMP_MD"

sort -t '|' -k3 -f "$CONFIG_FILE" | while IFS='|' read -r filename url title; do
    if [[ -z "$filename" || "$filename" == \#* ]]; then
        continue
    fi
    
    FILE_PATH="$OUTPUT_DIR/$filename"
    LAST_UPDATE="Unknown"
    
    if [[ -f "$FILE_PATH" ]]; then
        EXTRACTED=$(grep -m 1 -iE '^[!#] *(TimeUpdated|Updated|Last Update|Version|Last modified):' "$FILE_PATH" | cut -d':' -f2- | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        if [[ -n "$EXTRACTED" ]]; then
            LAST_UPDATE="${EXTRACTED:0:20}"
        else
            LAST_UPDATE=$(date -u +'%Y-%m-%d')
        fi
    fi
    
    MIRROR_LINK="https://hosts.domi.my.id/filters/$filename"
    
    echo "| $title | [Original]($url) | [Mirror]($MIRROR_LINK) | $LAST_UPDATE |" >> "$TEMP_MD"
done

awk '
// { print; system("cat temp_table.md"); skip=1; next }
// { skip=0 }
!skip { print }
' "$README_FILE" > temp_readme.md

mv temp_readme.md "$README_FILE"
rm "$TEMP_MD"

echo "README.md table successfully updated."
