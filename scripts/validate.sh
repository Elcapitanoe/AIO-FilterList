#!/usr/bin/env bash
# ==============================================================================
# AIO-FilterList - Codebase & Artifact Validation Script
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CHECK_ARTIFACTS=false
for arg in "$@"; do
    case "$arg" in
        --check-artifacts)
            CHECK_ARTIFACTS=true
            ;;
        -h|--help)
            echo "Usage: $0 [--check-artifacts]"
            exit 0
            ;;
    esac
done

ERRORS=0

log_info()  { echo -e "\033[0;34m[*] $1\033[0m"; }
log_ok()    { echo -e "\033[0;32m[✓] $1\033[0m"; }
log_error() { echo -e "\033[0;31m[✗] $1\033[0m" >&2; ERRORS=$((ERRORS + 1)); }

cd "$ROOT_DIR"

log_info "1. Validating shell script syntax..."
for sh_file in scripts/*.sh; do
    if [[ -f "$sh_file" ]]; then
        if bash -n "$sh_file"; then
            log_ok "Syntax valid: $sh_file"
        else
            log_error "Syntax error in $sh_file"
        fi
    fi
done

log_info "2. Validating config/sources.txt..."
CONFIG_FILE="config/sources.txt"
if [[ ! -f "$CONFIG_FILE" ]]; then
    log_error "Missing $CONFIG_FILE"
else
    line_no=0
    valid_sources=0
    declare -A seen_filenames=()
    declare -A seen_urls=()

    while IFS= read -r line || [[ -n "$line" ]]; do
        line_no=$((line_no + 1))
        # Strip CR
        line="${line//$'\r'/}"
        # Skip empty lines or comments
        [[ -z "${line// /}" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Check for exactly 3 pipe-separated fields
        IFS='|' read -r fname url title rest <<< "$line"
        fname="${fname#"${fname%%[![:space:]]*}"}"
        fname="${fname%"${fname##*[![:space:]]}"}"
        url="${url#"${url%%[![:space:]]*}"}"
        url="${url%"${url##*[![:space:]]}"}"
        title="${title#"${title%%[![:space:]]*}"}"
        title="${title%"${title##*[![:space:]]}"}"

        if [[ -n "${rest:-}" || -z "$fname" || -z "$url" || -z "$title" ]]; then
            log_error "Line $line_no in $CONFIG_FILE is malformed (expected: filename|url|title): $line"
            continue
        fi

        if [[ ! "$fname" =~ ^[a-zA-Z0-9._-]+\.txt$ ]]; then
            log_error "Line $line_no: Invalid filename format '$fname' (must be alphanumeric with .txt)"
        fi

        if [[ ! "$url" =~ ^https?:// ]]; then
            log_error "Line $line_no: Invalid URL scheme '$url'"
        fi

        if [[ -n "${seen_filenames[$fname]:-}" ]]; then
            log_error "Line $line_no: Duplicate filename '$fname' (first seen on line ${seen_filenames[$fname]})"
        else
            seen_filenames["$fname"]=$line_no
        fi

        if [[ -n "${seen_urls[$url]:-}" ]]; then
            log_error "Line $line_no: Duplicate URL '$url' (first seen on line ${seen_urls[$url]})"
        else
            seen_urls["$url"]=$line_no
        fi

        valid_sources=$((valid_sources + 1))
    done < "$CONFIG_FILE"

    log_ok "Verified $valid_sources source entries in $CONFIG_FILE"
fi

log_info "3. Validating project configuration & directories..."
if [[ -f "CNAME" ]]; then
    cname_content=$(<CNAME)
    cname_content="${cname_content//$'\r'/}"
    cname_content=$(echo "$cname_content" | xargs)
    if [[ "$cname_content" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        log_ok "CNAME verified: $cname_content"
    else
        log_error "CNAME content '$cname_content' does not appear to be a valid domain"
    fi
else
    log_error "Missing CNAME file"
fi

if [[ -d "filters" ]]; then
    filter_count=$(find filters -maxdepth 1 -name "*.txt" -type f | wc -l | tr -d ' ')
    log_ok "filters/ directory exists with $filter_count filter files"
else
    log_error "Missing filters/ directory"
fi

if [[ "$CHECK_ARTIFACTS" == "true" || -f "AIO_Filter_List.txt" ]]; then
    log_info "4. Validating output artifacts..."
    if [[ -f "AIO_Filter_List.txt" ]]; then
        rule_count=$(grep -vc '^[!#]' AIO_Filter_List.txt || true)
        if [[ "$rule_count" -lt 10000 ]]; then
            log_error "AIO_Filter_List.txt appears too small: only $rule_count rules found"
        else
            log_ok "AIO_Filter_List.txt verified ($rule_count active rules)"
        fi

        # Verify header title
        if head -n 10 AIO_Filter_List.txt | grep -q "^! Title:"; then
            log_ok "AIO_Filter_List.txt has valid Adblock metadata header"
        else
            log_error "AIO_Filter_List.txt is missing standard '! Title:' header"
        fi

        # Verify no Windows \r in file
        if head -n 50 AIO_Filter_List.txt | grep -q $'\r'; then
            log_error "AIO_Filter_List.txt contains carriage returns (\r)"
        fi
    else
        log_error "Missing AIO_Filter_List.txt"
    fi

    if [[ -f "build.log" ]]; then
        if grep -q "Final Payload" build.log; then
            log_ok "build.log structure verified"
        else
            log_error "build.log missing expected telemetry fields"
        fi
    fi
fi

if [[ "$ERRORS" -gt 0 ]]; then
    echo -e "\n\033[0;31mValidation failed with $ERRORS error(s).\033[0m" >&2
    exit 1
fi

echo -e "\n\033[0;32mValidation passed successfully.\033[0m"
exit 0
