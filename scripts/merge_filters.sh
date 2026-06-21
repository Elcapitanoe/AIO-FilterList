#!/bin/bash

set -eo pipefail

OUTPUT_DIR="filters"
MERGED_FILE="AIO_Filter_List.txt"
TEMP_FILE="temp_rules.txt"
FINAL_TEMP_FILE="final_rules.txt"
LOG_FILE="build.log"

VERSION=$(TZ="Asia/Jakarta" date +'%y.%m.%d.%H%M')
TIME_UPDATED=$(TZ="Asia/Jakarta" date +'%Y-%m-%d %H:%M:%S UTC+7')

echo "Building production artifact header..."
cat <<EOF > "$MERGED_FILE"
! Title: AIO Filter List
! Description: AIO Filter List Many Sources.
! Version: $VERSION
! TimeUpdated: $TIME_UPDATED
! Expires: 1 days
! Format: 1
! Maintainer: Elcapitanoe
! Homepage: https://github.com/Elcapitanoe/AIO-FilterList
! Issues: https://github.com/Elcapitanoe/AIO-FilterList/issues
! DownloadURL: https://hosts.domi.my.id/AIO_Filter_List.txt
!
!
EOF

echo "Merging rulesets and executing sanitization protocols..."
SOURCE_COUNT=0
> "$TEMP_FILE"

for file in "$OUTPUT_DIR"/*; do
    if [[ -f "$file" && "$file" != *".gitkeep"* && "$file" != *"index.html"* ]]; then
        
        SOURCE_COUNT=$((SOURCE_COUNT + 1))
        awk '{ sub(/\r$/, ""); if (/^[!#]/ || /^\[Adblock/ || /^$/) next; print }' "$file" >> "$TEMP_FILE"
    fi
done

RAW_COUNT=$(wc -l < "$TEMP_FILE")

echo "Executing high-performance sorting and deduplication..."
LC_ALL=C sort -u "$TEMP_FILE" > "$FINAL_TEMP_FILE"

FINAL_COUNT=$(wc -l < "$FINAL_TEMP_FILE")
DUPLICATE_COUNT=$((RAW_COUNT - FINAL_COUNT))

cat "$FINAL_TEMP_FILE" >> "$MERGED_FILE"
rm -f "$TEMP_FILE" "$FINAL_TEMP_FILE"

echo "Generating telemetry build log..."
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
EOF

echo "AIO Filter List artifact compiled successfully."
