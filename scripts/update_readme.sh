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
        EXTRACTED=$(grep -m 1 -iE '^[!#] *(TimeUpdated|Updated|Last Update|Version|Last modified):' "$FILE_PATH" | tr -d '\r' | cut -d':' -f2- | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        if [[ -n "$EXTRACTED" ]]; then
            CLEAN_DATE=$(echo "$EXTRACTED" | sed -E 's/[\.\+]+$//g' | sed 's/T/ /g')
            
            if [[ "$CLEAN_DATE" =~ ^[0-9]{12}$ ]]; then
                CLEAN_DATE=$(echo "$CLEAN_DATE" | sed -E 's/([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})/\1-\2-\3 \4:\5:00/')
            fi
            
            PARSED_DATE=$(date -u -d "$CLEAN_DATE" +'%Y-%m-%d %H:%M:%S' 2>/dev/null)
            
            if [[ -n "$PARSED_DATE" ]]; then
                LAST_UPDATE="$PARSED_DATE"
            else

                LAST_UPDATE="${CLEAN_DATE:0:19}"
            fi
        else

            LAST_UPDATE=$(date -u +'%Y-%m-%d %H:%M:%S')
        fi
    fi
    
    MIRROR_LINK="https://hosts.domi.my.id/filters/$filename"
    
    echo "| $title | [Original]($url) | [Mirror]($MIRROR_LINK) | $LAST_UPDATE |" >> "$TEMP_MD"
done

echo "Injecting table into README.md safely..."

TEMP_README="temp_readme_build.md"

awk -v r="$TEMP_MD" '
// {
    print
    system("cat " r)
    skip=1
    next
}
// {
    skip=0
}
!skip { print }
' "$README_FILE" > "$TEMP_README"

mv "$TEMP_README" "$README_FILE"
rm "$TEMP_MD"

echo "README.md table successfully updated and dates normalized."
