#!/bin/bash

OUTPUT_DIR="filters"
MERGED_FILE="AIO_Filter_List.txt"
TEMP_FILE="temp_rules.txt"
LOG_FILE="build.log"

VERSION=$(TZ="Asia/Jakarta" date +'%y.%m.%d.%H%M')
TIME_UPDATED=$(TZ="Asia/Jakarta" date +'%Y-%m-%d %H:%M:%S UTC+7')

echo "Building custom header..."
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

echo "Merging lists and stripping original headers..."
SOURCE_COUNT=0
for file in "$OUTPUT_DIR"/*; do
    if [[ -f "$file" && "$file" != *".gitkeep"* && "$file" != *"index.html"* ]]; then
        ((SOURCE_COUNT++))
        grep -Ev '^[!#]|^\[Adblock.*\]$' "$file" | grep -v '^$' >> "$TEMP_FILE"
    fi
done

# Calculate raw rules count
RAW_COUNT=$(wc -l < "$TEMP_FILE")

echo "Removing duplicate rules..."
awk '!seen[$0]++' "$TEMP_FILE" >> "$MERGED_FILE"

# Calculate final rules count (subtracting the 12 header lines)
FINAL_COUNT=$(wc -l < "$MERGED_FILE")
FINAL_COUNT=$((FINAL_COUNT - 12))

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
EOF

echo "AIO Filter List and build log successfully generated."
