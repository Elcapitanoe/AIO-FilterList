#!/usr/bin/env bash
# Validate shell syntax, source configuration, project metadata, and build artifacts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

CHECK_ARTIFACTS=false
for arg in "$@"; do
    case "$arg" in
        --check-artifacts) CHECK_ARTIFACTS=true ;;
        -h|--help)
            printf 'Usage: %s [--check-artifacts]\n' "$0"
            exit 0
            ;;
        *)
            printf '[ERROR] Unknown argument: %s\n' "$arg" >&2
            exit 2
            ;;
    esac
done

OUTPUT_DIR="${OUTPUT_DIR:-filters}"
MERGED_FILE="${MERGED_FILE:-AIO_Filter_List.txt}"
LOG_FILE="${LOG_FILE:-build.log}"
ERRORS=0

log_info()  { printf '\033[0;34m[*] %s\033[0m\n' "$1"; }
log_ok()    { printf '\033[0;32m[OK] %s\033[0m\n' "$1"; }
log_error() { printf '\033[0;31m[ERROR] %s\033[0m\n' "$1" >&2; ERRORS=$((ERRORS + 1)); }
trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
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

log_info '1. Validating shell script syntax...'
for sh_file in scripts/*.sh tests/*.sh; do
    [[ -f "$sh_file" ]] || continue
    if bash -n "$sh_file"; then
        log_ok "Syntax valid: $sh_file"
    else
        log_error "Syntax error in $sh_file"
    fi
done

log_info '2. Validating config/sources.txt...'
CONFIG_FILE='config/sources.txt'
if [[ ! -f "$CONFIG_FILE" ]]; then
    log_error "Missing $CONFIG_FILE"
else
    LINE_NO=0
    VALID_SOURCES=0
    declare -A SEEN_FILENAMES=() SEEN_URLS=()

    while IFS= read -r line || [[ -n "$line" ]]; do
        LINE_NO=$((LINE_NO + 1))
        line="${line%$'\r'}"
        trimmed_line="$(trim "$line")"
        [[ -z "$trimmed_line" || "$trimmed_line" == \#* ]] && continue

        pipes="${line//[^|]/}"
        if [[ ${#pipes} -ne 2 ]]; then
            log_error "Line $LINE_NO in $CONFIG_FILE must have exactly three fields: filename|url|title."
            continue
        fi

        IFS='|' read -r fname url title <<< "$line"
        fname="$(trim "${fname//$'\r'/}")"
        url="$(trim "${url//$'\r'/}")"
        title="$(trim "${title//$'\r'/}")"
        ENTRY_VALID=true

        if [[ ! "$fname" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*\.txt$ || "$fname" == *..* ]]; then
            log_error "Line $LINE_NO: unsafe or invalid filename '$fname'."
            ENTRY_VALID=false
        fi
        if [[ ! "$url" =~ ^https?://[^/?#[:space:]]+([/?#][^[:space:]]*)?$ ]]; then
            log_error "Line $LINE_NO: invalid HTTP(S) URL '$url'."
            ENTRY_VALID=false
        fi
        if [[ -z "$title" ]]; then
            log_error "Line $LINE_NO: empty display title."
            ENTRY_VALID=false
        fi
        if [[ "$fname" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*\.txt$ && "$fname" != *..* \
            && -n "${SEEN_FILENAMES[$fname]:-}" ]]; then
            log_error "Line $LINE_NO: duplicate filename '$fname' (first seen on line ${SEEN_FILENAMES[$fname]})."
            ENTRY_VALID=false
        fi
        if [[ "$url" =~ ^https?://[^[:space:]/]+([/?#][^[:space:]]*)?$ \
            && -n "${SEEN_URLS[$url]:-}" ]]; then
            log_error "Line $LINE_NO: duplicate URL '$url' (first seen on line ${SEEN_URLS[$url]})."
            ENTRY_VALID=false
        fi

        if [[ "$ENTRY_VALID" == true ]]; then
            SEEN_FILENAMES["$fname"]=$LINE_NO
            SEEN_URLS["$url"]=$LINE_NO
            VALID_SOURCES=$((VALID_SOURCES + 1))
        fi
    done < "$CONFIG_FILE"

    if (( VALID_SOURCES == 0 )); then
        log_error "No valid source entries found in $CONFIG_FILE."
    else
        log_ok "Verified $VALID_SOURCES source entries in $CONFIG_FILE"
    fi
fi

log_info '3. Validating project metadata and directories...'
if [[ -f CNAME ]]; then
    CNAME_CONTENT="$(trim "$(<CNAME)")"
    CNAME_CONTENT="${CNAME_CONTENT//$'\r'/}"
    if [[ "$CNAME_CONTENT" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        log_ok "CNAME verified: $CNAME_CONTENT"
    else
        log_error "CNAME content '$CNAME_CONTENT' does not appear to be a valid domain."
    fi
else
    log_error 'Missing CNAME file.'
fi

if [[ -f LICENSE ]]; then
    log_ok 'LICENSE file exists.'
else
    log_error 'Missing LICENSE file referenced by README.md.'
fi

if [[ -d "$OUTPUT_DIR" ]]; then
    FILTER_COUNT="$(find "$OUTPUT_DIR" -maxdepth 1 -type f -name '*.txt' | wc -l | tr -d '[:space:]')"
    log_ok "$OUTPUT_DIR/ directory exists with $FILTER_COUNT filter file(s)."
else
    log_error "Missing filter directory '$OUTPUT_DIR'."
fi

if [[ "$CHECK_ARTIFACTS" == true ]]; then
    log_info '4. Validating output artifacts...'
    if [[ -f "$MERGED_FILE" ]]; then
        RULE_COUNT="$(awk '!/^[!#]/ && !/^[[:space:]]*$/ { count++ } END { print count + 0 }' "$MERGED_FILE")"
        if (( RULE_COUNT < 10000 )); then
            log_error "$MERGED_FILE appears too small: only $RULE_COUNT active rules found."
        else
            log_ok "$MERGED_FILE has $RULE_COUNT active rules."
        fi

        if head -n 10 "$MERGED_FILE" | grep -Fxq '! Title: AIO Filter List'; then
            log_ok 'Merged list has the expected title metadata.'
        else
            log_error "$MERGED_FILE is missing the expected '! Title: AIO Filter List' header."
        fi
        if ! head -n 10 "$MERGED_FILE" | grep -q '^! Version: '; then
            log_error "$MERGED_FILE is missing version metadata."
        fi
        if ! head -n 10 "$MERGED_FILE" | grep -q '^! TimeUpdated: '; then
            log_error "$MERGED_FILE is missing update-time metadata."
        fi
        if ! head -n 10 "$MERGED_FILE" | grep -q '^! Expires: '; then
            log_error "$MERGED_FILE is missing expiration metadata."
        fi
        if ! head -n 10 "$MERGED_FILE" | grep -q '^! Format: '; then
            log_error "$MERGED_FILE is missing format metadata."
        fi
        if LC_ALL=C grep -q $'\r' "$MERGED_FILE"; then
            log_error "$MERGED_FILE contains carriage returns (CR)."
        else
            log_ok 'Merged list has no carriage returns.'
        fi

        if LC_ALL=C awk '
            /^[!#]/ || /^[[:space:]]*$/ { next }
            {
                current = "x" $0
                if (seen && current <= previous) { bad = 1; exit }
                previous = current
                seen = 1
            }
            END { if (bad) exit 1 }
        ' "$MERGED_FILE"; then
            log_ok 'Active rules are sorted and contain no adjacent duplicates.'
        else
            log_error 'Active rules are not strictly sorted or contain duplicates.'
        fi
    else
        log_error "Missing merged artifact '$MERGED_FILE'."
    fi

    if [[ -f "$LOG_FILE" ]]; then
        for field in 'Build Timestamp' 'Version tag' 'Sources Synced' 'Input signature' 'Merged SHA256' 'Raw Rules' 'Duplicates Drop' 'Final Payload'; do
            if grep -q "^${field}[[:space:]]*:" "$LOG_FILE"; then
                :
            else
                log_error "$LOG_FILE is missing required field '$field'."
            fi
        done
        if [[ -f "$MERGED_FILE" ]]; then
            LOG_HASH="$(awk -F: '$1 ~ /^Merged SHA256[[:space:]]*$/ {gsub(/[[:space:]]/, "", $2); print $2; exit}' "$LOG_FILE")"
            ACTUAL_HASH="$(hash_file "$MERGED_FILE")"
            if [[ -n "$LOG_HASH" && "$LOG_HASH" == "$ACTUAL_HASH" ]]; then
                log_ok 'build.log checksum matches the merged artifact.'
            else
                log_error 'build.log checksum does not match the merged artifact.'
            fi
        fi
    else
        log_error "Missing build telemetry file '$LOG_FILE'."
    fi

    if [[ "$CHECK_ARTIFACTS" == true && -f "$CONFIG_FILE" ]]; then
        while IFS='|' read -r fname _url _title rest || [[ -n "${fname:-}" ]]; do
            fname="$(trim "${fname//$'\r'/}")"
            [[ -z "$fname" || "$fname" == \#* ]] && continue
            if [[ ! -s "$OUTPUT_DIR/$fname" ]]; then
                log_error "Configured source mirror '$OUTPUT_DIR/$fname' is missing or empty."
            fi
        done < "$CONFIG_FILE"
    fi
fi

if (( ERRORS > 0 )); then
    printf '\nValidation failed with %s error(s).\n' "$ERRORS" >&2
    exit 1
fi
printf '\nValidation passed successfully.\n'
