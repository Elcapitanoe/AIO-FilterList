#!/usr/bin/env bash
# Generate the JSON consumed by the GitHub Pages dashboard.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

log_error() {
    printf '[ERROR] %s\n' "$1" >&2
}

read_log_field() {
    local key="$1"
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
    ' build.log
}

if [[ ! -s build.log ]]; then
    log_error 'Build log is missing or empty.'
    exit 1
fi
if [[ ! -f config/sources.txt ]]; then
    log_error 'config/sources.txt not found.'
    exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
    log_error 'jq is required to generate site/data.json.'
    exit 1
fi

build_timestamp="$(read_log_field 'Build Timestamp')"
version="$(read_log_field 'Version tag')"
raw_rules="$(read_log_field 'Raw Rules')"
duplicates_removed="$(read_log_field 'Duplicates Drop')"
active_rules="$(read_log_field 'Final Payload')"
raw_rules="${raw_rules%% *}"
duplicates_removed="${duplicates_removed%% *}"
active_rules="${active_rules%% *}"

if [[ -z "$build_timestamp" || ! "$raw_rules" =~ ^[0-9]+$ \
    || ! "$duplicates_removed" =~ ^[0-9]+$ || ! "$active_rules" =~ ^[0-9]+$ ]]; then
    log_error 'Build telemetry in build.log is incomplete or invalid.'
    exit 1
fi

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/aio-site.XXXXXX")"
TMP_JSON="$(mktemp "site/data.json.tmp.XXXXXX")"
trap 'rm -rf "$TMP_DIR"; rm -f "$TMP_JSON"' EXIT
TMP_SOURCES="$TMP_DIR/sources.jsonl"
: > "$TMP_SOURCES"

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

source_count=0
LC_ALL=C sort -t '|' -k3 -f config/sources.txt > "$TMP_DIR/sources.sorted"
while IFS= read -r source_line || [[ -n "${source_line:-}" ]]; do
    source_line="${source_line%$'\r'}"
    trimmed_line="$(trim "$source_line")"
    [[ -z "$trimmed_line" || "$trimmed_line" == \#* ]] && continue

    pipes="${source_line//[^|]/}"
    if [[ ${#pipes} -ne 2 ]]; then
        log_error "Malformed source entry: $source_line"
        exit 1
    fi

    IFS='|' read -r filename upstream_url title <<< "$source_line"
    filename="$(trim "$filename")"
    upstream_url="$(trim "$upstream_url")"
    title="$(trim "$title")"
    mirror_path="filters/$filename"
    if [[ ! -s "$mirror_path" ]]; then
        log_error "Configured source mirror '$mirror_path' is missing or empty."
        exit 1
    fi

    raw_lines="$(awk 'END { print NR + 0 }' "$mirror_path")"
    jq -cn \
        --arg title "$title" \
        --arg filename "$filename" \
        --arg upstream_url "$upstream_url" \
        --arg mirror_url "https://hosts.domi.my.id/filters/$filename" \
        --arg last_updated "$build_timestamp" \
        --argjson raw_lines "$raw_lines" \
        '{title:$title, filename:$filename, upstream_url:$upstream_url,
          mirror_url:$mirror_url, raw_lines:$raw_lines, last_updated:$last_updated}' \
        >> "$TMP_SOURCES"
    source_count=$((source_count + 1))
done < "$TMP_DIR/sources.sorted"

if [[ "$source_count" -eq 0 ]]; then
    log_error 'No sources found in config/sources.txt.'
    exit 1
fi

mkdir -p site
jq -n \
    --arg generated_at "$build_timestamp" \
    --arg version "${version:-unknown}" \
    --argjson active_rules "$active_rules" \
    --argjson raw_rules "$raw_rules" \
    --argjson duplicates_removed "$duplicates_removed" \
    --argjson source_count "$source_count" \
    --slurpfile sources "$TMP_SOURCES" \
    '{generated_at:$generated_at, version:$version,
      metrics:{active_rules:$active_rules, raw_rules:$raw_rules,
      duplicates_removed:$duplicates_removed, source_count:$source_count},
      sources:$sources}' > "$TMP_JSON"

mv -f "$TMP_JSON" site/data.json
printf '==> Generated site/data.json for %s sources.\n' "$source_count"
