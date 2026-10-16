#!/usr/bin/env bash
# Download configured upstream lists with bounded concurrency and atomic updates.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

CONFIG_FILE="${CONFIG_FILE:-config/sources.txt}"
OUTPUT_DIR="${OUTPUT_DIR:-filters}"
MAX_PARALLEL="${MAX_PARALLEL:-4}"
USER_AGENT="${USER_AGENT:-Mozilla/5.0 (compatible; AIO-FilterList-Bot/1.0; +https://github.com/Elcapitanoe/AIO-FilterList)}"

log_error() {
    printf '[ERROR] %s\n' "$1" >&2
}

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

hash_stream() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 | awk '{print $1}'
    else
        log_error 'Neither sha256sum nor shasum is available.'
        return 1
    fi
}

hash_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        log_error 'Neither sha256sum nor shasum is available.'
        return 1
    fi
}

hash_files_signature() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$@" | awk '{print $1}' | hash_stream
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$@" | awk '{print $1}' | hash_stream
    else
        log_error 'Neither sha256sum nor shasum is available.'
        return 1
    fi
}

if [[ ! -f "$CONFIG_FILE" ]]; then
    log_error "Source configuration file '$CONFIG_FILE' does not exist."
    exit 1
fi

if [[ ! "$MAX_PARALLEL" =~ ^[1-9][0-9]*$ || ${#MAX_PARALLEL} -gt 2 ]] \
    || (( MAX_PARALLEL > 32 )); then
    log_error "MAX_PARALLEL must be an integer from 1 to 32; received '$MAX_PARALLEL'."
    exit 1
fi

declare -a SOURCE_FILENAMES=() SOURCE_URLS=() SOURCE_TITLES=()
declare -A SEEN_FILENAMES=() SEEN_URLS=()
CONFIG_ERRORS=0
LINE_NO=0

while IFS= read -r line || [[ -n "$line" ]]; do
    LINE_NO=$((LINE_NO + 1))
    line="${line%$'\r'}"
    trimmed_line="$(trim "$line")"
    [[ -z "$trimmed_line" || "$trimmed_line" == \#* ]] && continue

    pipes="${line//[^|]/}"
    if [[ ${#pipes} -ne 2 ]]; then
        log_error "Line $LINE_NO in $CONFIG_FILE must contain exactly three fields: filename|url|title."
        CONFIG_ERRORS=$((CONFIG_ERRORS + 1))
        continue
    fi

    IFS='|' read -r filename url title <<< "$line"
    filename="$(trim "${filename//$'\r'/}")"
    url="$(trim "${url//$'\r'/}")"
    title="$(trim "${title//$'\r'/}")"
    entry_valid=true

    if [[ ! "$filename" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*\.txt$ || "$filename" == *..* ]]; then
        log_error "Line $LINE_NO has an unsafe or invalid filename: '$filename'."
        entry_valid=false
    fi
    if [[ ! "$url" =~ ^https?://[^/?#[:space:]]+([/?#][^[:space:]]*)?$ ]]; then
        log_error "Line $LINE_NO has an invalid HTTP(S) URL: '$url'."
        entry_valid=false
    fi
    if [[ -z "$title" ]]; then
        log_error "Line $LINE_NO has an empty display title."
        entry_valid=false
    fi

    if [[ "$filename" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*\.txt$ && "$filename" != *..* \
        && -n "${SEEN_FILENAMES[$filename]:-}" ]]; then
        log_error "Line $LINE_NO duplicates filename '$filename' (first seen on line ${SEEN_FILENAMES[$filename]})."
        entry_valid=false
    fi
    if [[ "$url" =~ ^https?://[^/?#[:space:]]+([/?#][^[:space:]]*)?$ \
        && -n "${SEEN_URLS[$url]:-}" ]]; then
        log_error "Line $LINE_NO duplicates URL '$url' (first seen on line ${SEEN_URLS[$url]})."
        entry_valid=false
    fi

    if [[ "$entry_valid" == true ]]; then
        SEEN_FILENAMES["$filename"]=$LINE_NO
        SEEN_URLS["$url"]=$LINE_NO
        SOURCE_FILENAMES+=("$filename")
        SOURCE_URLS+=("$url")
        SOURCE_TITLES+=("$title")
    else
        CONFIG_ERRORS=$((CONFIG_ERRORS + 1))
    fi
done < "$CONFIG_FILE"

if (( CONFIG_ERRORS > 0 )); then
    log_error "Refusing to fetch because $CONFIG_ERRORS configuration error(s) were found."
    exit 1
fi
if (( ${#SOURCE_FILENAMES[@]} == 0 )); then
    log_error "No upstream sources are configured in '$CONFIG_FILE'."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
STAGE_DIR="$(mktemp -d "$OUTPUT_DIR/.aio-fetch.XXXXXX")"
trap 'rm -rf "$STAGE_DIR"' EXIT

fetch_source() {
    local fname="$1" url="$2" title="$3"
    local staged="$STAGE_DIR/$fname"
    local tmp

    tmp="$(mktemp "$STAGE_DIR/.${fname}.tmp.XXXXXX")"
    trap 'rm -f "$tmp"' EXIT

    printf '[FETCHING] %s (%s)...\n' "$title" "$fname"
    if ! curl \
        --silent \
        --show-error \
        --location \
        --fail \
        --retry 3 \
        --retry-delay 2 \
        --connect-timeout 15 \
        --max-time 180 \
        --user-agent "$USER_AGENT" \
        --output "$tmp" \
        "$url"; then
        log_error "Failed to fetch '$title' from $url."
        return 1
    fi

    if [[ ! -s "$tmp" ]]; then
        log_error "Received an empty response for '$title' from $url."
        return 1
    fi

    # Reject common successful-HTTP error pages before replacing a good mirror.
    if head -c 4096 "$tmp" | grep -Eiq '^[[:space:]]*(<!doctype[[:space:]]+html|<html([[:space:]>]|$)|<head([[:space:]>]|$)|<\?xml)'; then
        log_error "The response for '$title' appears to be HTML/XML, not a filter list."
        return 1
    fi

    if ! awk '
        {
            sub(/\r$/, "")
            sub(/^[[:space:]]+/, "")
            sub(/[[:space:]]+$/, "")
            if ($0 == "" || /^!/ || /^#/ || /^\[Adblock/) next
            found = 1
            exit
        }
        END { if (found) exit 0; exit 1 }
    ' "$tmp"; then
        log_error "The response for '$title' contains no active filter rules."
        return 1
    fi

    # Make published lists readable to the web server and other local users.
    chmod 644 "$tmp"
    # Keep validated downloads in a staging directory until every source succeeds.
    # The staged directory lives under OUTPUT_DIR, so the final rename stays on one filesystem.
    mv -f "$tmp" "$staged"
    printf '[VALIDATED] %s (%s)\n' "$title" "$fname"
}

FAILED_COUNT=0
declare -a FAILED_SOURCES=() PIDS=() BATCH_TITLES=() BATCH_FILENAMES=()

wait_for_batch() {
    local i
    for i in "${!PIDS[@]}"; do
        if ! wait "${PIDS[$i]}"; then
            FAILED_COUNT=$((FAILED_COUNT + 1))
            FAILED_SOURCES+=("${BATCH_TITLES[$i]} (${BATCH_FILENAMES[$i]})")
        fi
    done
    PIDS=()
    BATCH_TITLES=()
    BATCH_FILENAMES=()
}

printf '==> Fetching %s upstream filter lists (parallel limit: %s)...\n' \
    "${#SOURCE_FILENAMES[@]}" "$MAX_PARALLEL"

for i in "${!SOURCE_FILENAMES[@]}"; do
    fetch_source "${SOURCE_FILENAMES[$i]}" "${SOURCE_URLS[$i]}" "${SOURCE_TITLES[$i]}" &
    PIDS+=("$!")
    BATCH_TITLES+=("${SOURCE_TITLES[$i]}")
    BATCH_FILENAMES+=("${SOURCE_FILENAMES[$i]}")

    if (( ${#PIDS[@]} >= MAX_PARALLEL )); then
        wait_for_batch
    fi
done

if (( ${#PIDS[@]} > 0 )); then
    wait_for_batch
fi

if (( FAILED_COUNT > 0 )); then
    printf '%s\n' '--------------------------------------------------' >&2
    log_error "$FAILED_COUNT upstream source(s) failed; no existing source mirrors were changed."
    printf '  - %s\n' "${FAILED_SOURCES[@]}" >&2
    printf '%s\n' '--------------------------------------------------' >&2
    exit 1
fi

# Publish the staged files only after the entire configured source set passes.
for i in "${!SOURCE_FILENAMES[@]}"; do
    fname="${SOURCE_FILENAMES[$i]}"
    title="${SOURCE_TITLES[$i]}"
    staged="$STAGE_DIR/$fname"
    dest="$OUTPUT_DIR/$fname"
    if [[ -f "$dest" ]] && cmp -s "$staged" "$dest"; then
        chmod 644 "$dest"
        printf '[UNCHANGED] %s (%s)\n' "$title" "$fname"
        continue
    fi
    mv -f "$staged" "$dest"
    lines="$(wc -l < "$dest" | tr -d '[:space:]')"
    printf '[UPDATED]   %s -> %s (%s lines)\n' "$title" "$fname" "$lines"
done

# The config is the source of truth. Remove stale mirrors only after every
# configured source has been downloaded and published successfully.
shopt -s nullglob
for existing_file in "$OUTPUT_DIR"/*.txt; do
    [[ -f "$existing_file" || -L "$existing_file" ]] || continue
    existing_name="${existing_file##*/}"
    if [[ "$existing_name" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*\.txt$ && "$existing_name" != *..* \
        && -n "${SEEN_FILENAMES[$existing_name]:-}" ]]; then
        continue
    fi
    rm -f -- "$existing_file"
    printf '[REMOVED]   Stale mirror not present in config: %s\n' "$existing_name"
done

printf '==> All %s upstream filter lists synchronized successfully.\n' "${#SOURCE_FILENAMES[@]}"
