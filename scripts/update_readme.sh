#!/usr/bin/env bash
# ==============================================================================
# AIO-FilterList - README Dynamic Updater
# Injects dynamic mirror tables and telemetry stats into README.md markers.
# ==============================================================================
set -euo pipefail

CONFIG_FILE="${CONFIG_FILE:-config/sources.txt}"
README_FILE="${README_FILE:-README.md}"
OUTPUT_DIR="${OUTPUT_DIR:-filters}"
LOG_FILE="${LOG_FILE:-build.log}"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[ERROR] Config file '$CONFIG_FILE' not found." >&2
    exit 1
fi

if [[ ! -f "$README_FILE" ]]; then
    echo "[ERROR] README file '$README_FILE' not found." >&2
    exit 1
fi

TMP_DIR=$(mktemp -d -t aio-readme-XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

TMP_TABLE="$TMP_DIR/table.md"
TMP_STATS="$TMP_DIR/stats.md"
TMP_OUTPUT="$TMP_DIR/README.md.tmp"

format_number() {
    local num="$1"
    awk -v n="$num" '
    BEGIN {
        s = "" n
        len = length(s)
        res = ""
        for (i = 1; i <= len; i++) {
            res = res substr(s, i, 1)
            if ((len - i) > 0 && (len - i) % 3 == 0) res = res ","
        }
        print res
    }'
}

# ------------------------------------------------------------------------------
# 1. Generate Telemetry Stats Table
# ------------------------------------------------------------------------------
if [[ -f "$LOG_FILE" ]]; then
    BUILD_TIMESTAMP=$(grep "Build Timestamp" "$LOG_FILE" | cut -d':' -f2- | xargs || true)
    VERSION_TAG=$(grep "Version tag" "$LOG_FILE" | cut -d':' -f2- | xargs || true)
    SOURCES_SYNCED=$(grep "Sources Synced" "$LOG_FILE" | cut -d':' -f2- | xargs || true)
    RAW_RULES=$(grep "Raw Rules" "$LOG_FILE" | cut -d':' -f2- | tr -d ',' | xargs || true)
    DUPLICATES_DROP=$(grep "Duplicates Drop" "$LOG_FILE" | cut -d':' -f2- | tr -d ',' | xargs || true)
    FINAL_PAYLOAD=$(grep "Final Payload" "$LOG_FILE" | awk '{print $4}' | tr -d ',' | xargs || true)

    FMT_RAW=$(format_number "${RAW_RULES:-0}")
    FMT_DUP=$(format_number "${DUPLICATES_DROP:-0}")
    FMT_FINAL=$(format_number "${FINAL_PAYLOAD:-0}")

    cat <<EOF > "$TMP_STATS"
| Metric | Value |
| :--- | :--- |
| **Active Filter Rules** | \`$FMT_FINAL\` |
| **Raw Rules Processed** | \`$FMT_RAW\` |
| **Duplicates Removed** | \`$FMT_DUP\` |
| **Sources Synced** | \`$SOURCES_SYNCED\` |
| **Version Tag** | \`$VERSION_TAG\` |
| **Last Synchronized** | \`$BUILD_TIMESTAMP\` |
EOF
else
    cat <<EOF > "$TMP_STATS"
| Metric | Value |
| :--- | :--- |
| **Status** | *Build log not yet generated.* |
EOF
fi

# ------------------------------------------------------------------------------
# 2. Generate Upstream Mirrors Table
# ------------------------------------------------------------------------------
cat <<EOF > "$TMP_TABLE"
| Filter Name | Upstream | Main Mirror | jsDelivr CDN | Edge CDN | Last Updated |
| :--- | :---: | :---: | :---: | :---: | :---: |
EOF

sort -t '|' -k3 -f "$CONFIG_FILE" | while IFS='|' read -r filename url title rest || [[ -n "$filename" ]]; do
    filename="${filename//$'\r'/}"
    url="${url//$'\r'/}"
    title="${title//$'\r'/}"

    filename="${filename#"${filename%%[![:space:]]*}"}"
    filename="${filename%"${filename##*[![:space:]]}"}"
    url="${url#"${url%%[![:space:]]*}"}"
    url="${url%"${url##*[![:space:]]}"}"
    title="${title#"${title%%[![:space:]]*}"}"
    title="${title%"${title##*[![:space:]]}"}"

    [[ -z "$filename" || "$filename" =~ ^# ]] && continue

    file_path="$OUTPUT_DIR/$filename"

    if [[ -n $(git status --porcelain "$file_path" 2>/dev/null) ]]; then
        last_updated=$(TZ='Asia/Jakarta' date +'%Y-%m-%d %H:%M:%S')
    else
        last_updated=$(git log -1 --format="%cd" --date=format:'%Y-%m-%d %H:%M:%S' -- "$file_path" 2>/dev/null || true)
        if [[ -z "$last_updated" ]]; then
            last_updated=$(TZ='Asia/Jakarta' date +'%Y-%m-%d %H:%M:%S')
        fi
    fi

    mirror_main="https://hosts.domi.my.id/filters/$filename"
    mirror_jsdelivr="https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/$filename"
    mirror_edge="https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/$filename"

    echo "| **$title** | [Source]($url) | [hosts.domi]($mirror_main) | [jsDelivr]($mirror_jsdelivr) | [cdn.domi]($mirror_edge) | \`$last_updated\` |" >> "$TMP_TABLE"
done

# ------------------------------------------------------------------------------
# 3. Inject into README.md using Markers
# ------------------------------------------------------------------------------
if ! grep -q "<!-- AUTOGEN_TABLE_START -->" "$README_FILE"; then
    echo "[WARNING] Marker '<!-- AUTOGEN_TABLE_START -->' not found in $README_FILE." >&2
    echo "[INFO] Appending generated content..."
    {
        echo ""
        echo "## Upstream Sources and Mirrors"
        echo ""
        echo "<!-- AUTOGEN_TABLE_START -->"
        cat "$TMP_TABLE"
        echo "<!-- AUTOGEN_TABLE_END -->"
    } >> "$README_FILE"
    exit 0
fi

# Inject stats table if marker exists
if grep -q "<!-- AUTOGEN_STATS_START -->" "$README_FILE"; then
    awk -v stats_file="$TMP_STATS" '
        BEGIN { in_block = 0 }
        /<!-- AUTOGEN_STATS_START -->/ {
            print
            while ((getline line < stats_file) > 0) print line
            close(stats_file)
            in_block = 1
            next
        }
        /<!-- AUTOGEN_STATS_END -->/ {
            in_block = 0
        }
        !in_block { print }
    ' "$README_FILE" > "$TMP_OUTPUT"
    mv -f "$TMP_OUTPUT" "$README_FILE"
fi

# Inject mirror sources table
awk -v table_file="$TMP_TABLE" '
    BEGIN { in_block = 0 }
    /<!-- AUTOGEN_TABLE_START -->/ {
        print
        while ((getline line < table_file) > 0) print line
        close(table_file)
        in_block = 1
        next
    }
    /<!-- AUTOGEN_TABLE_END -->/ {
        in_block = 0
    }
    !in_block { print }
' "$README_FILE" > "$TMP_OUTPUT"
mv -f "$TMP_OUTPUT" "$README_FILE"

echo "==> README.md updated successfully with latest mirrors and telemetry."
