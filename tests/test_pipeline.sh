#!/usr/bin/env bash
# Offline regression tests for merge caching, normalization, deduplication, and README output.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/aio-tests.XXXXXX")"
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/config" "$TEST_DIR/filters"
cat > "$TEST_DIR/config/sources.txt" <<'EOF_SOURCES'
alpha.txt|https://example.test/alpha.txt|Alpha List
beta.txt|https://example.test/beta.txt|Beta List
EOF_SOURCES

cat > "$TEST_DIR/filters/alpha.txt" <<'EOF_ALPHA'
! source header
[Adblock Plus 2.0]
  ||example.com^  
||duplicate.example^
0.0.0.0 ads.example.com
EOF_ALPHA
cat > "$TEST_DIR/filters/beta.txt" <<'EOF_BETA'
# source header
||duplicate.example^
0.0.0.0 ads.example.com
||z.example^
EOF_BETA

run_merge() {
    CONFIG_FILE="$TEST_DIR/config/sources.txt" \
    OUTPUT_DIR="$TEST_DIR/filters" \
    MERGED_FILE="$TEST_DIR/AIO_Filter_List.txt" \
    LOG_FILE="$TEST_DIR/build.log" \
        "$ROOT_DIR/scripts/merge_filters.sh"
}

assert_equal() {
    local expected="$1" actual="$2" message="$3"
    if [[ "$expected" != "$actual" ]]; then
        printf '[FAIL] %s: expected <%s>, received <%s>\n' "$message" "$expected" "$actual" >&2
        exit 1
    fi
}

hash_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    else
        shasum -a 256 "$1" | awk '{print $1}'
    fi
}

printf '[TEST] Downloader rejects invalid payloads without overwriting failed sources\n'
mkdir -p "$TEST_DIR/bin" "$TEST_DIR/fetch-filters"
cat > "$TEST_DIR/config/fetch-sources.txt" <<'EOF_FETCH_SOURCES'
good.txt|https://example.test/good.txt|Good List
bad.txt|https://example.test/bad.txt|Bad List
EOF_FETCH_SOURCES
printf 'old-good\n' > "$TEST_DIR/fetch-filters/good.txt"
printf 'keep-this-file\n' > "$TEST_DIR/fetch-filters/bad.txt"
printf 'stale mirror\n' > "$TEST_DIR/fetch-filters/stale.txt"
cat > "$TEST_DIR/bin/curl" <<'EOF_CURL'
#!/usr/bin/env bash
set -euo pipefail
output=''
url=''
while (( $# > 0 )); do
    case "$1" in
        --output) output="$2"; shift 2 ;;
        --user-agent|--retry|--retry-delay|--connect-timeout|--max-time) shift 2 ;;
        --*) shift ;;
        *) url="$1"; shift ;;
    esac
done
case "$url" in
    https://example.test/good.txt) printf '||new-good.example^\n' > "$output" ;;
    https://example.test/bad.txt) printf '<!doctype html>\n<html>upstream error</html>\n' > "$output" ;;
    *) exit 22 ;;
esac
EOF_CURL
chmod +x "$TEST_DIR/bin/curl"
if PATH="$TEST_DIR/bin:$PATH" \
    CONFIG_FILE="$TEST_DIR/config/fetch-sources.txt" \
    OUTPUT_DIR="$TEST_DIR/fetch-filters" \
    MAX_PARALLEL=1 \
        "$ROOT_DIR/scripts/fetch_filters.sh" > "$TEST_DIR/fetch.log" 2>&1; then
    printf '[FAIL] Downloader accepted a simulated HTML error response.\n' >&2
    exit 1
fi
grep -Fxq 'old-good' "$TEST_DIR/fetch-filters/good.txt"
grep -Fxq 'keep-this-file' "$TEST_DIR/fetch-filters/bad.txt"
test -f "$TEST_DIR/fetch-filters/stale.txt"
if find "$TEST_DIR/fetch-filters" -maxdepth 1 -name '.*.tmp.*' -print -quit | grep -q .; then
    printf '[FAIL] Downloader left temporary files behind.\n' >&2
    exit 1
fi
cat > "$TEST_DIR/config/fetch-sources.txt" <<'EOF_GOOD_ONLY'
good.txt|https://example.test/good.txt|Good List
EOF_GOOD_ONLY
PATH="$TEST_DIR/bin:$PATH" \
CONFIG_FILE="$TEST_DIR/config/fetch-sources.txt" \
OUTPUT_DIR="$TEST_DIR/fetch-filters" \
MAX_PARALLEL=1 \
    "$ROOT_DIR/scripts/fetch_filters.sh" > "$TEST_DIR/fetch-success.log" 2>&1
test ! -e "$TEST_DIR/fetch-filters/bad.txt"
test ! -e "$TEST_DIR/fetch-filters/stale.txt"
if find "$TEST_DIR/fetch-filters" -maxdepth 1 -name '.aio-fetch.*' -print -quit | grep -q .; then
    printf '[FAIL] Downloader left its staging directory behind.\n' >&2
    exit 1
fi
grep -Fxq '||new-good.example^' "$TEST_DIR/fetch-filters/good.txt"

printf '[TEST] Compile and deduplicate fixture rules\n'
run_merge >/dev/null
RULE_COUNT="$(awk '!/^[!#]/ && !/^[[:space:]]*$/ { n++ } END { print n + 0 }' "$TEST_DIR/AIO_Filter_List.txt")"
assert_equal 4 "$RULE_COUNT" 'deduplicated rule count'
grep -Fxq '||example.com^' "$TEST_DIR/AIO_Filter_List.txt"
grep -Fxq '||duplicate.example^' "$TEST_DIR/AIO_Filter_List.txt"
grep -Fxq '0.0.0.0 ads.example.com' "$TEST_DIR/AIO_Filter_List.txt"
if grep -Fxq '[Adblock Plus 2.0]' "$TEST_DIR/AIO_Filter_List.txt"; then
    printf '[FAIL] Adblock section markers leaked into output.\n' >&2
    exit 1
fi

printf '[TEST] No-op merge preserves the generated files\n'
FIRST_LIST_HASH="$(hash_file "$TEST_DIR/AIO_Filter_List.txt")"
FIRST_LOG_HASH="$(hash_file "$TEST_DIR/build.log")"
run_merge >/dev/null
assert_equal "$FIRST_LIST_HASH" "$(hash_file "$TEST_DIR/AIO_Filter_List.txt")" 'no-op artifact checksum'
assert_equal "$FIRST_LOG_HASH" "$(hash_file "$TEST_DIR/build.log")" 'no-op build log checksum'

printf '[TEST] Metadata-only upstream changes do not rewrite the merged list\n'
printf '! refreshed metadata only\n' >> "$TEST_DIR/filters/alpha.txt"
run_merge >/dev/null
assert_equal "$FIRST_LIST_HASH" "$(hash_file "$TEST_DIR/AIO_Filter_List.txt")" 'metadata-only artifact checksum'

printf '[TEST] Rule changes refresh the published list\n'
printf '||new.example^\n' >> "$TEST_DIR/filters/alpha.txt"
run_merge >/dev/null
RULE_COUNT="$(awk '!/^[!#]/ && !/^[[:space:]]*$/ { n++ } END { print n + 0 }' "$TEST_DIR/AIO_Filter_List.txt")"
assert_equal 5 "$RULE_COUNT" 'updated rule count'

printf '[TEST] README markers are updated safely and idempotently\n'
cat > "$TEST_DIR/README.md" <<'EOF_README'
# Test README
<!-- AUTOGEN_STATS_START -->
old stats
<!-- AUTOGEN_STATS_END -->
<!-- AUTOGEN_TABLE_START -->
old table
<!-- AUTOGEN_TABLE_END -->
EOF_README
run_readme() {
    CONFIG_FILE="$TEST_DIR/config/sources.txt" \
    README_FILE="$TEST_DIR/README.md" \
    OUTPUT_DIR="$TEST_DIR/filters" \
    LOG_FILE="$TEST_DIR/build.log" \
        "$ROOT_DIR/scripts/update_readme.sh"
}
run_readme >/dev/null
grep -Fq '| **Active Filter Rules** | `5` |' "$TEST_DIR/README.md"
grep -Fq '**Alpha List**' "$TEST_DIR/README.md"
alpha_line="$(grep -n -F '**Alpha List**' "$TEST_DIR/README.md" | cut -d: -f1)"
beta_line="$(grep -n -F '**Beta List**' "$TEST_DIR/README.md" | cut -d: -f1)"
if (( alpha_line >= beta_line )); then
    printf '[FAIL] README source table is not alphabetically sorted.\n' >&2
    exit 1
fi
FIRST_README_HASH="$(hash_file "$TEST_DIR/README.md")"
run_readme >/dev/null
assert_equal "$FIRST_README_HASH" "$(hash_file "$TEST_DIR/README.md")" 'README idempotence'
cp "$TEST_DIR/README.md" "$TEST_DIR/README.before-bad-markers.md"
sed '/AUTOGEN_TABLE_END/d' "$TEST_DIR/README.md" > "$TEST_DIR/README.bad.md"
cp "$TEST_DIR/README.bad.md" "$TEST_DIR/README.bad.before.md"
if CONFIG_FILE="$TEST_DIR/config/sources.txt" \
    README_FILE="$TEST_DIR/README.bad.md" \
    OUTPUT_DIR="$TEST_DIR/filters" \
    LOG_FILE="$TEST_DIR/build.log" \
        "$ROOT_DIR/scripts/update_readme.sh" >/dev/null 2>&1; then
    printf '[FAIL] README updater accepted a missing marker.\n' >&2
    exit 1
fi
assert_equal "$(hash_file "$TEST_DIR/README.bad.before.md")" \
    "$(hash_file "$TEST_DIR/README.bad.md")" 'README fail-safe behavior'

printf '[PASS] All pipeline regression tests passed.\n'
