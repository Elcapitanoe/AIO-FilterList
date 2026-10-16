#!/usr/bin/env bash
# Update the generated telemetry and upstream mirror tables in README.md.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

CONFIG_FILE="${CONFIG_FILE:-config/sources.txt}"
README_FILE="${README_FILE:-README.md}"
OUTPUT_DIR="${OUTPUT_DIR:-filters}"
LOG_FILE="${LOG_FILE:-build.log}"

log_error() {
    printf '[ERROR] %s\n' "$1" >&2
}

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

if [[ ! -f "$CONFIG_FILE" ]]; then
    log_error "Config file '$CONFIG_FILE' not found."
    exit 1
fi
if [[ ! -f "$README_FILE" ]]; then
    log_error "README file '$README_FILE' not found."
    exit 1
fi

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/aio-readme.XXXXXX")"
trap 'rm -rf "$TMP_DIR"; rm -f "$TMP_OUTPUT"' EXIT
TMP_TABLE="$TMP_DIR/table.md"
TMP_STATS="$TMP_DIR/stats.md"
TMP_SORTED="$TMP_DIR/sources.sorted"
TMP_OUTPUT="$(mktemp "${README_FILE}.tmp.XXXXXX")"

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
        }
    '
}

# Parse known fields without relying on spaces or fixed awk column positions.
read_log_field() {
    local key="$1"
    [[ -f "$LOG_FILE" ]] || return 0
    awk -v key="$key" '
        {
            separator = index($0, ":")
            if (!separator) next
            label = substr($0, 1, separator - 1)
            value = substr($0, separator + 1)
            sub(/^[[:space:]]*/, "", label)
            sub(/[[:space:]]*$/, "", label)
            sub(/^[[:space:]]*/, "", value)
            sub(/[[:space:]]*$/, "", value)
            if (label == key) { print value; exit }
        }
    ' "$LOG_FILE"
}

if [[ -f "$LOG_FILE" ]]; then
    BUILD_TIMESTAMP="$(read_log_field 'Build Timestamp')"
    VERSION_TAG="$(read_log_field 'Version tag')"
    SOURCES_SYNCED="$(read_log_field 'Sources Synced')"
    RAW_RULES="$(read_log_field 'Raw Rules')"
    DUPLICATES_DROP="$(read_log_field 'Duplicates Drop')"
    FINAL_PAYLOAD="$(read_log_field 'Final Payload')"

    # The generated log stores comma-free integers; strip labels defensively for older logs.
    RAW_RULES="${RAW_RULES%% *}"
    DUPLICATES_DROP="${DUPLICATES_DROP%% *}"
    FINAL_PAYLOAD="${FINAL_PAYLOAD%% *}"
    [[ "$RAW_RULES" =~ ^[0-9]+$ ]] || RAW_RULES=0
    [[ "$DUPLICATES_DROP" =~ ^[0-9]+$ ]] || DUPLICATES_DROP=0
    [[ "$FINAL_PAYLOAD" =~ ^[0-9]+$ ]] || FINAL_PAYLOAD=0

    cat <<EOF_STATS > "$TMP_STATS"
| Metric | Value |
| :--- | :--- |
| **Active Filter Rules** | \`$(format_number "$FINAL_PAYLOAD")\` |
| **Raw Rules Processed** | \`$(format_number "$RAW_RULES")\` |
| **Duplicates Removed** | \`$(format_number "$DUPLICATES_DROP")\` |
| **Sources Synced** | \`${SOURCES_SYNCED:-0 upstream lists}\` |
| **Version Tag** | \`${VERSION_TAG:-unknown}\` |
| **Last Synchronized** | \`${BUILD_TIMESTAMP:-unknown}\` |
EOF_STATS
else
    cat <<EOF_STATS > "$TMP_STATS"
| Metric | Value |
| :--- | :--- |
| **Status** | *Build log not yet generated.* |
EOF_STATS
fi

cat <<'EOF_TABLE' > "$TMP_TABLE"
| Filter Name | Upstream | Main Mirror | jsDelivr CDN | Edge CDN | Last Updated |
| :--- | :---: | :---: | :---: | :---: | :---: |
EOF_TABLE

LC_ALL=C sort -t '|' -k3 -f "$CONFIG_FILE" > "$TMP_SORTED"
while IFS= read -r source_line || [[ -n "${source_line:-}" ]]; do
    source_line="${source_line%$'\r'}"
    trimmed_line="$(trim "$source_line")"
    [[ -z "$trimmed_line" || "$trimmed_line" == \#* ]] && continue

    pipes="${source_line//[^|]/}"
    if [[ ${#pipes} -ne 2 ]]; then
        log_error "Malformed source entry in $CONFIG_FILE: $source_line"
        exit 1
    fi

    IFS='|' read -r filename url title <<< "$source_line"
    filename="$(trim "${filename//$'\r'/}")"
    url="$(trim "${url//$'\r'/}")"
    title="$(trim "${title//$'\r'/}")"
    if [[ ! "$filename" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*\.txt$ || "$filename" == *..* \
        || ! "$url" =~ ^https?://[^/?#[:space:]]+([/?#][^[:space:]]*)?$ || -z "$title" ]]; then
        log_error "Invalid source entry in $CONFIG_FILE: $source_line"
        exit 1
    fi

    file_path="$OUTPUT_DIR/$filename"
    if [[ ! -s "$file_path" ]]; then
        log_error "Configured source mirror '$file_path' is missing or empty."
        exit 1
    fi
    last_updated=""
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        if [[ -n "$(git status --porcelain -- "$file_path" 2>/dev/null || true)" ]]; then
            last_updated="$(TZ=Asia/Jakarta date +'%Y-%m-%d %H:%M:%S')"
        else
            last_updated="$(TZ=Asia/Jakarta git log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M:%S' -- "$file_path" 2>/dev/null || true)"
        fi
    fi
    # Archives commonly rewrite every file's mtime, so do not present filesystem
    # timestamps as source-update times when Git history is unavailable.
    if [[ -z "$last_updated" ]]; then
        last_updated='unknown'
    fi

    mirror_main="https://hosts.domi.my.id/filters/$filename"
    mirror_jsdelivr="https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/$filename"
    mirror_edge="https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/$filename"
    printf '| **%s** | [Source](%s) | [hosts.domi](%s) | [jsDelivr](%s) | [cdn.domi](%s) | `%s` |\n' \
        "$title" "$url" "$mirror_main" "$mirror_jsdelivr" "$mirror_edge" "$last_updated" >> "$TMP_TABLE"
done < "$TMP_SORTED"

# Fail closed rather than risk deleting README content if markers are missing or duplicated.
for marker in AUTOGEN_STATS_START AUTOGEN_STATS_END AUTOGEN_TABLE_START AUTOGEN_TABLE_END; do
    count="$(grep -Fxc "<!-- $marker -->" "$README_FILE" || true)"
    if [[ "$count" != 1 ]]; then
        log_error "README must contain exactly one '<!-- $marker -->' marker (found $count)."
        exit 1
    fi
done

if ! awk '
    /<!-- AUTOGEN_STATS_START -->/ { stats_start = NR }
    /<!-- AUTOGEN_STATS_END -->/ { stats_end = NR }
    /<!-- AUTOGEN_TABLE_START -->/ { table_start = NR }
    /<!-- AUTOGEN_TABLE_END -->/ { table_end = NR }
    END {
        if (!stats_start || !stats_end || !table_start || !table_end) exit 1
        if (stats_start >= stats_end || table_start >= table_end) exit 1
        if (!(stats_end < table_start || table_end < stats_start)) exit 1
    }
' "$README_FILE"; then
    log_error 'README auto-generation markers are out of order or their blocks overlap.'
    exit 1
fi

awk -v stats_file="$TMP_STATS" -v table_file="$TMP_TABLE" '
    /<!-- AUTOGEN_STATS_START -->/ {
        print
        while ((getline line < stats_file) > 0) print line
        close(stats_file)
        in_stats = 1
        next
    }
    /<!-- AUTOGEN_STATS_END -->/ {
        in_stats = 0
        print
        next
    }
    /<!-- AUTOGEN_TABLE_START -->/ {
        print
        while ((getline line < table_file) > 0) print line
        close(table_file)
        in_table = 1
        next
    }
    /<!-- AUTOGEN_TABLE_END -->/ {
        in_table = 0
        print
        next
    }
    !in_stats && !in_table { print }
' "$README_FILE" > "$TMP_OUTPUT"

if ! cmp -s "$TMP_OUTPUT" "$README_FILE"; then
    chmod 644 "$TMP_OUTPUT"
    mv -f "$TMP_OUTPUT" "$README_FILE"
    printf '%s\n' '==> README.md updated with current telemetry and mirror links.'
else
    printf '%s\n' '==> README.md is already current; no rewrite needed.'
fi
chmod 644 "$README_FILE"
