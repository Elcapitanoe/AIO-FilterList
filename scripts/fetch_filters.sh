#!/usr/bin/env bash
# ==============================================================================
# AIO-FilterList - Upstream Filter Fetcher
# Fetches upstream filter lists concurrently with staging, retry, and safety checks.
# ==============================================================================
set -euo pipefail

CONFIG_FILE="${CONFIG_FILE:-config/sources.txt}"
OUTPUT_DIR="${OUTPUT_DIR:-filters}"
USER_AGENT="${USER_AGENT:-Mozilla/5.0 (compatible; AIO-FilterList-Bot/1.0; +https://github.com/Elcapitanoe/AIO-FilterList)}"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[ERROR] Source configuration file '$CONFIG_FILE' does not exist." >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "==> Initiating parallel upstream synchronization..."

PIDS=()
TITLES=()
FILENAMES=()

fetch_source() {
    local fname="$1"
    local url="$2"
    local title="$3"
    local dest="$OUTPUT_DIR/$fname"
    local tmp="$OUTPUT_DIR/.${fname}.tmp"

    # Ensure cleanup of tmp file on exit
    trap 'rm -f "$tmp"' EXIT

    echo "[FETCHING] $title ($fname)..."
    if curl -sSL \
        -A "$USER_AGENT" \
        --fail \
        --retry 3 \
        --retry-delay 2 \
        --connect-timeout 15 \
        --max-time 60 \
        "$url" -o "$tmp"; then

        if [[ -s "$tmp" ]]; then
            mv -f "$tmp" "$dest"
            local lines
            lines=$(wc -l < "$dest" | tr -d ' ')
            echo "[SUCCESS]  $title -> $fname ($lines lines)"
            return 0
        else
            echo "[ERROR]    Received empty response for $title ($url)" >&2
            rm -f "$tmp"
            return 1
        fi
    else
        echo "[ERROR]    Failed to fetch $title from $url" >&2
        rm -f "$tmp"
        return 1
    fi
}

while IFS='|' read -r filename url title rest || [[ -n "$filename" ]]; do
    # Remove carriage returns and trim whitespace
    filename="${filename//$'\r'/}"
    url="${url//$'\r'/}"
    title="${title//$'\r'/}"

    filename="${filename#"${filename%%[![:space:]]*}"}"
    filename="${filename%"${filename##*[![:space:]]}"}"
    url="${url#"${url%%[![:space:]]*}"}"
    url="${url%"${url##*[![:space:]]}"}"
    title="${title#"${title%%[![:space:]]*}"}"
    title="${title%"${title##*[![:space:]]}"}"

    # Skip comments and blank lines
    [[ -z "$filename" || "$filename" =~ ^# ]] && continue

    fetch_source "$filename" "$url" "$title" &
    PIDS+=("$!")
    TITLES+=("$title")
    FILENAMES+=("$filename")
done < "$CONFIG_FILE"

FAILED_COUNT=0
FAILED_SOURCES=()

for i in "${!PIDS[@]}"; do
    pid="${PIDS[$i]}"
    title="${TITLES[$i]}"
    fname="${FILENAMES[$i]}"

    if ! wait "$pid"; then
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_SOURCES+=("$title ($fname)")
    fi
done

if [[ "$FAILED_COUNT" -gt 0 ]]; then
    echo "--------------------------------------------------" >&2
    echo "[FATAL] $FAILED_COUNT upstream source(s) failed to synchronize:" >&2
    for failed in "${FAILED_SOURCES[@]}"; do
        echo "  - $failed" >&2
    done
    echo "--------------------------------------------------" >&2
    exit 1
fi

echo "==> All ${#PIDS[@]} upstream filter lists synchronized successfully."
