#!/bin/bash

OUTPUT_DIR="filters"
MERGED_FILE="AIO_Filter_List.txt"
TEMP_FILE="temp_rules.txt"
LOG_FILE="build.log"

VERSION=$(date -u +'%Y.%m.%d.%H%M')
TIME_UPDATED=$(date -u +'%Y-%m-%d %H:%M:%S UTC')

echo "Building custom header..."
cat <<EOF > "$MERGED_FILE"
! Title: AIO Filter List
! Description: AIO Filter List Many Sources.
! Version: $VERSION
! TimeUpdated: $TIME_UPDATED
! Homepage: https://github.com/Elcapitanoe/AIO-FilterList
EOF

echo "Merging lists and stripping original headers..."
SOURCE_COUNT=0
for file in "$OUTPUT_DIR"/*; do
    if [[ -f "$file" && "$file" != *".gitkeep"* ]]; then
        # Count the number of source files processed
        ((SOURCE_COUNT++))
        grep -Ev '^[!#]' "$file" | grep -v '^$' >> "$TEMP_FILE"
    fi
done

# Calculate raw rules count
RAW_COUNT=$(wc -l < "$TEMP_FILE")

echo "Removing duplicate rules..."
awk '!seen[$0]++' "$TEMP_FILE" >> "$MERGED_FILE"

# Calculate final rules count (subtracting the 5 header lines)
FINAL_COUNT=$(wc -l < "$MERGED_FILE")
FINAL_COUNT=$((FINAL_COUNT - 5))

# Calculate removed duplicates
DUPLICATE_COUNT=$((RAW_COUNT - FINAL_COUNT))

# Clean up
rm "$TEMP_FILE"

echo "Generating build log..."
cat <<EOF > "$LOG_FILE"
==================================================
        AIO FILTER LIST - AUTOMATED BUILD LOG     
==================================================
Build Timestamp : $TIME_UPDATED
Version tag     : $VERSION
Sources Synced  : $SOURCE_COUNT upstream lists
==================================================
Raw Rules       : $(printf "%'d" "$RAW_COUNT")
Duplicates Drop : $(printf "%'d" "$DUPLICATE_COUNT")
Final Payload   : $(printf "%'d" "$FINAL_COUNT") active rules
==================================================
Status          : SUCCESS
==================================================
EOF

echo "AIO Filter List and build log successfully generated."
