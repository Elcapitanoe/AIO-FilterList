#!/usr/bin/env bash
# Sanitize, deduplicate, and compile configured upstream filter lists.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

CONFIG_FILE="${CONFIG_FILE:-config/sources.txt}"
OUTPUT_DIR="${OUTPUT_DIR:-filters}"
MERGED_FILE="${MERGED_FILE:-AIO_Filter_List.txt}"
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
    log_error "Source configuration file '$CONFIG_FILE' does not exist."
    exit 1
fi
if [[ ! -d "$OUTPUT_DIR" ]]; then
    log_error "Filter directory '$OUTPUT_DIR' does not exist."
    exit 1
fi

# Compile only explicitly configured sources; stray or obsolete .txt files are ignored.
declare -a FILTER_FILES=()
declare -A SEEN_SOURCE_FILENAMES=() SEEN_SOURCE_URLS=()
LINE_NO=0
while IFS= read -r line || [[ -n "$line" ]]; do
    LINE_NO=$((LINE_NO + 1))
    line="${line%$'\r'}"
    trimmed_line="$(trim "$line")"
    [[ -z "$trimmed_line" || "$trimmed_line" == \#* ]] && continue

    pipes="${line//[^|]/}"
    if [[ ${#pipes} -ne 2 ]]; then
        log_error "Line $LINE_NO in $CONFIG_FILE must contain exactly three fields: filename|url|title."
        exit 1
    fi

    IFS='|' read -r filename url title <<< "$line"
    filename="$(trim "${filename//$'\r'/}")"
    url="$(trim "${url//$'\r'/}")"
    title="$(trim "${title//$'\r'/}")"
    if [[ ! "$filename" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*\.txt$ || "$filename" == *..* ]]; then
        log_error "Line $LINE_NO has an unsafe or invalid filename: '$filename'."
        exit 1
    fi
    if [[ ! "$url" =~ ^https?://[^/?#[:space:]]+([/?#][^[:space:]]*)?$ || -z "$title" ]]; then
        log_error "Line $LINE_NO has an invalid URL or empty title."
        exit 1
    fi
    if [[ -n "${SEEN_SOURCE_FILENAMES[$filename]:-}" ]]; then
        log_error "Line $LINE_NO duplicates configured filename '$filename'."
        exit 1
    fi
    if [[ -n "${SEEN_SOURCE_URLS[$url]:-}" ]]; then
        log_error "Line $LINE_NO duplicates configured URL '$url'."
        exit 1
    fi
    SEEN_SOURCE_FILENAMES["$filename"]=$LINE_NO
    SEEN_SOURCE_URLS["$url"]=$LINE_NO

    source_file="$OUTPUT_DIR/$filename"
    if [[ ! -s "$source_file" ]]; then
        log_error "Configured source '$source_file' is missing or empty. Run scripts/fetch_filters.sh first."
        exit 1
    fi
    FILTER_FILES+=("$source_file")
done < "$CONFIG_FILE"

SOURCE_COUNT="${#FILTER_FILES[@]}"
if (( SOURCE_COUNT == 0 )); then
    log_error "No valid upstream sources found in '$CONFIG_FILE'."
    exit 1
fi

mkdir -p "$(dirname "$MERGED_FILE")" "$(dirname "$LOG_FILE")"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/aio-merge.XXXXXX")"
MERGED_TMP=""
LOG_TMP=""
cleanup() {
    rm -rf "$TMP_DIR"
    [[ -z "$MERGED_TMP" ]] || rm -f "$MERGED_TMP"
    [[ -z "$LOG_TMP" ]] || rm -f "$LOG_TMP"
}
trap cleanup EXIT

RAW_TEMP="$TMP_DIR/raw_rules.txt"
DEDUP_TEMP="$TMP_DIR/dedup_rules.txt"
CURRENT_RULES_TEMP="$TMP_DIR/current_rules.txt"

# Hash configuration, source contents, and this compiler. Identical inputs can skip
# an expensive scan/sort of millions of rules, while compiler changes invalidate cache.
INPUT_SIGNATURE="$(sha256sum "$CONFIG_FILE" "$SCRIPT_DIR/merge_filters.sh" "${FILTER_FILES[@]}" | awk '{print $1}' | sha256sum | awk '{print $1}')"
CURRENT_SIGNATURE=""
STORED_OUTPUT_HASH=""
CURRENT_OUTPUT_HASH=""
CURRENT_LOG_VERSION=""
if [[ -f "$LOG_FILE" ]]; then
    CURRENT_SIGNATURE="$(awk -F: '$1 ~ /^Input signature[[:space:]]*$/ {gsub(/[[:space:]]/, "", $2); print $2; exit}' "$LOG_FILE")"
    STORED_OUTPUT_HASH="$(awk -F: '$1 ~ /^Merged SHA256[[:space:]]*$/ {gsub(/[[:space:]]/, "", $2); print $2; exit}' "$LOG_FILE")"
fi

HEADER_VALID=false
if [[ -f "$MERGED_FILE" ]] \
    && head -n 10 "$MERGED_FILE" | grep -Fxq '! Title: AIO Filter List' \
    && head -n 10 "$MERGED_FILE" | grep -q '^! Version: ' \
    && head -n 10 "$MERGED_FILE" | grep -q '^! TimeUpdated: ' \
    && head -n 10 "$MERGED_FILE" | grep -q '^! Expires: ' \
    && head -n 10 "$MERGED_FILE" | grep -q '^! Format: '; then
    HEADER_VALID=true
    CURRENT_OUTPUT_HASH="$(sha256sum "$MERGED_FILE" | awk '{print $1}')"
    CURRENT_LOG_VERSION="$(awk -F': ' '/^! Version:/ {print $2; exit}' "$MERGED_FILE")"
fi

if [[ "$HEADER_VALID" == true && -n "$CURRENT_SIGNATURE" && "$CURRENT_SIGNATURE" == "$INPUT_SIGNATURE" \
    && -n "$STORED_OUTPUT_HASH" && "$STORED_OUTPUT_HASH" == "$CURRENT_OUTPUT_HASH" \
    && -f "$LOG_FILE" ]] \
    && grep -q '^Build Timestamp[[:space:]]*:' "$LOG_FILE" \
    && grep -q '^Version tag[[:space:]]*:' "$LOG_FILE" \
    && grep -q '^Sources Synced[[:space:]]*:' "$LOG_FILE" \
    && grep -q '^Raw Rules[[:space:]]*:' "$LOG_FILE" \
    && grep -q '^Duplicates Drop[[:space:]]*:' "$LOG_FILE" \
    && grep -q '^Final Payload[[:space:]]*:' "$LOG_FILE"; then
    chmod 644 "$MERGED_FILE" "$LOG_FILE"
    printf '==> Inputs and output are unchanged (%s sources); skipping merge.\n' "$SOURCE_COUNT"
    exit 0
fi

sanitize_rules() {
    awk '
        {
            sub(/\r$/, "")
            sub(/^[[:space:]]+/, "")
            sub(/[[:space:]]+$/, "")
            if ($0 == "" || /^!/ || /^#/ || /^\[Adblock/) next
            print
        }
    ' "$@"
}

printf '==> Sanitizing %s configured upstream filter lists...\n' "$SOURCE_COUNT"
sanitize_rules "${FILTER_FILES[@]}" > "$RAW_TEMP"
RAW_COUNT="$(wc -l < "$RAW_TEMP" | tr -d '[:space:]')"
if (( RAW_COUNT == 0 )); then
    log_error 'No active rules were found across the configured source files.'
    exit 1
fi

printf '==> Sorting and deduplicating %s raw rules...\n' "$RAW_COUNT"
LC_ALL=C sort -u "$RAW_TEMP" > "$DEDUP_TEMP"
rm -f "$RAW_TEMP"
FINAL_COUNT="$(wc -l < "$DEDUP_TEMP" | tr -d '[:space:]')"
DUPLICATE_COUNT=$((RAW_COUNT - FINAL_COUNT))
if (( FINAL_COUNT == 0 )); then
    log_error 'The merged rule payload is empty; refusing to publish it.'
    exit 1
fi

RULES_CHANGED=true
if [[ "$HEADER_VALID" == true ]]; then
    sanitize_rules "$MERGED_FILE" > "$CURRENT_RULES_TEMP"
    if cmp -s "$DEDUP_TEMP" "$CURRENT_RULES_TEMP"; then
        RULES_CHANGED=false
    fi
    rm -f "$CURRENT_RULES_TEMP"
fi

TIME_UPDATED="$(TZ=Asia/Jakarta date +'%Y-%m-%d %H:%M:%S UTC+7')"
VERSION="$(TZ=Asia/Jakarta date +'%y.%m.%d.%H%M')"

if [[ "$RULES_CHANGED" == true ]]; then
    MERGED_TMP="$(mktemp "${MERGED_FILE}.tmp.XXXXXX")"
    cat <<EOF_HEADER > "$MERGED_TMP"
! Title: AIO Filter List
! Description: Consolidated and deduplicated adblock filter list aggregated from multiple community sources.
! Version: $VERSION
! TimeUpdated: $TIME_UPDATED
! Expires: 1 days
! Format: 1
! Maintainer: Elcapitanoe
! Homepage: https://github.com/Elcapitanoe/AIO-FilterList
! Issues: https://github.com/Elcapitanoe/AIO-FilterList/issues
! DownloadURL: https://hosts.domi.my.id/AIO_Filter_List.txt
!
EOF_HEADER
    cat "$DEDUP_TEMP" >> "$MERGED_TMP"
    chmod 644 "$MERGED_TMP"
    mv -f "$MERGED_TMP" "$MERGED_FILE"
    MERGED_TMP=""
    CURRENT_OUTPUT_HASH="$(sha256sum "$MERGED_FILE" | awk '{print $1}')"
    CURRENT_LOG_VERSION="$VERSION"
    printf '==> The rule payload changed; refreshed %s.\n' "$MERGED_FILE"
else
    printf '==> Rule payload is unchanged; preserving the published list metadata.\n'
    CURRENT_OUTPUT_HASH="$(sha256sum "$MERGED_FILE" | awk '{print $1}')"
    if [[ -z "$CURRENT_LOG_VERSION" ]]; then
        CURRENT_LOG_VERSION="$(awk -F': ' '/^! Version:/ {print $2; exit}' "$MERGED_FILE")"
    fi
fi

# Update telemetry only when input state or output actually changed. This keeps
# scheduled no-op runs from rewriting the 50+ MB merged artifact and README daily.
LOG_TMP="$(mktemp "${LOG_FILE}.tmp.XXXXXX")"
cat <<EOF_LOG > "$LOG_TMP"
==================================================
        AIO FILTER LIST - AUTOMATED BUILD LOG
==================================================
Build Timestamp : $TIME_UPDATED
Version tag     : $CURRENT_LOG_VERSION
Sources Synced  : $SOURCE_COUNT upstream lists
Input signature : $INPUT_SIGNATURE
Merged SHA256   : $CURRENT_OUTPUT_HASH
==================================================
Raw Rules       : $RAW_COUNT
Duplicates Drop : $DUPLICATE_COUNT
Final Payload   : $FINAL_COUNT active rules
==================================================
EOF_LOG
chmod 644 "$LOG_TMP"
mv -f "$LOG_TMP" "$LOG_FILE"
LOG_TMP=""
chmod 644 "$MERGED_FILE" "$LOG_FILE"

printf '%s\n' '=================================================='
printf '%s\n' ' AIO Filter List Build Complete'
printf ' Version tag     : %s\n' "$CURRENT_LOG_VERSION"
printf ' Sources Synced  : %s\n' "$SOURCE_COUNT"
printf ' Raw Rules       : %s\n' "$RAW_COUNT"
printf ' Duplicates Drop : %s\n' "$DUPLICATE_COUNT"
printf ' Final Payload   : %s\n' "$FINAL_COUNT"
printf ' Output Artifact : %s\n' "$MERGED_FILE"
printf '%s\n' '=================================================='
