#!/bin/bash

OUTPUT_DIR="filters"
MERGED_FILE="AIO_Filter_List.txt"
TEMP_FILE="temp_rules.txt"

VERSION=$(date -u +'%Y.%m.%d.%H%M')
TIME_UPDATED=$(date -u +'%Y-%m-%d %H:%M:%S UTC')

echo "Building custom header..."
cat <<EOF > "$MERGED_FILE"
! Title: AIO Filter List
! Description: AIO Filter List Many Sources.
! Version: $VERSION
! TimeUpdated: $TIME_UPDATED
! Homepage: https://github.com/Elcapitanoe/Adblock-FilterList
EOF

echo "Merging lists and stripping original headers..."
for file in "$OUTPUT_DIR"/*; do
    if [[ -f "$file" && "$file" != *".gitkeep"* ]]; then
        # Drop lines starting with ! or # and remove empty lines
        grep -Ev '^[!#]' "$file" | grep -v '^$' >> "$TEMP_FILE"
    fi
done

echo "Removing duplicate rules..."
# Keep only unique lines to optimize the final blocklist
awk '!seen[$0]++' "$TEMP_FILE" >> "$MERGED_FILE"

# Clean up the working file
rm "$TEMP_FILE"

echo "AIO Filter List successfully generated."
