#!/usr/bin/env bash
# ==============================================================================
# AIO-FilterList - Rule Aggregator & Compiler
# Sanitizes, deduplicates, and compiles upstream lists into a unified filter list.
# ==============================================================================
set -euo pipefail

OUTPUT_DIR="${OUTPUT_DIR:-filters}"
MERGED_FILE="${MERGED_FILE:-AIO_Filter_List.txt}"
LOG_FILE="${LOG_FILE:-build.log}"

if [[ ! -d "$OUTPUT_DIR" ]]; then
    echo "[ERROR] Filter directory '$OUTPUT_DIR' does not exist." >&2
    exit 1
fi

shopt -s nullglob
FILTER_FILES=("$OUTPUT_DIR"/*.txt)
SOURCE_COUNT="${#FILTER_FILES[@]}"

if [[ "$SOURCE_COUNT" -eq 0 ]]; then
    echo "[ERROR] No .txt filter files found in '$OUTPUT_DIR'." >&2
    exit 1
fi

VERSION=$(TZ="Asia/Jakarta" date +'%y.%m.%d.%H%M')
TIME_UPDATED=$(TZ="Asia/Jakarta" date +'%Y-%m-%d %H:%M:%S UTC+7')

TMP_DIR=$(mktemp -d -t aio-merge-XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

RAW_TEMP="$TMP_DIR/raw_rules.txt"
DEDUP_TEMP="$TMP_DIR/dedup_rules.txt"
TARGET_TEMP="$TMP_DIR/merged.txt"

echo "==> Sanitizing upstream filter rulesets..."
# Stream all filter files through single awk filter pass:
# 1. Strip Windows CR (\r)
# 2. Skip Adblock/hosts comments (! or #), Adblock headers, and blank lines
awk '
    {
        sub(/\r$/, "")
        if (/^[[:space:]]*[!#]/ || /^[[:space:]]*\[Adblock/ || /^[[:space:]]*$/) next
        print
    }
' "${FILTER_FILES[@]}" > "$RAW_TEMP"

RAW_COUNT=$(wc -l < "$RAW_TEMP" | tr -d ' ')

echo "==> Sorting and deduplicating $RAW_COUNT raw rules..."
LC_ALL=C sort -u "$RAW_TEMP" > "$DEDUP_TEMP"

FINAL_COUNT=$(wc -l < "$DEDUP_TEMP" | tr -d ' ')
DUPLICATE_COUNT=$((RAW_COUNT - FINAL_COUNT))

echo "==> Generating standard Adblock metadata header..."
cat <<EOF > "$TARGET_TEMP"
! Title: AIO Filter List
! Description: Consolidated and deduplicated adblock filter list aggregated from multiple trusted community sources.
! Version: $VERSION
! TimeUpdated: $TIME_UPDATED
! Expires: 1 days
! Format: 1
! Maintainer: Elcapitanoe
! Homepage: https://github.com/Elcapitanoe/AIO-FilterList
! Issues: https://github.com/Elcapitanoe/AIO-FilterList/issues
! DownloadURL: https://hosts.domi.my.id/AIO_Filter_List.txt
!
EOF

cat "$DEDUP_TEMP" >> "$TARGET_TEMP"
mv -f "$TARGET_TEMP" "$MERGED_FILE"

echo "==> Generating telemetry build log..."
cat <<EOF > "$LOG_FILE"
==================================================
        AIO FILTER LIST - AUTOMATED BUILD LOG     
==================================================
Build Timestamp : $TIME_UPDATED
Version tag     : $VERSION
Sources Synced  : $SOURCE_COUNT upstream lists
==================================================
Raw Rules       : $RAW_COUNT
Duplicates Drop : $DUPLICATE_COUNT
Final Payload   : $FINAL_COUNT active rules
==================================================
EOF

echo "=================================================="
echo " AIO Filter List Build Complete"
echo "=================================================="
echo " Version tag     : $VERSION"
echo " Sources Synced  : $SOURCE_COUNT"
echo " Raw Rules       : $RAW_COUNT"
echo " Duplicates Drop : $DUPLICATE_COUNT"
echo " Final Payload   : $FINAL_COUNT active rules"
echo " Output Artifact : $MERGED_FILE"
echo "=================================================="
