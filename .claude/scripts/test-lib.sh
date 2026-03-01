#!/bin/bash
# lib.sh 단위 테스트
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

PASS_COUNT=0
FAIL_COUNT=0

assert_pass() {
  local label="$1"
  shift
  # Run in subshell to isolate ERRORS array
  if (source "$SCRIPT_DIR/lib.sh"; LOGS_DIR="$TMP_DIR"; "$@"; [[ ${#ERRORS[@]} -eq 0 ]]) 2>/dev/null; then
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "  FAIL: $label (expected PASS)"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

assert_fail() {
  local label="$1"
  shift
  if (source "$SCRIPT_DIR/lib.sh"; LOGS_DIR="$TMP_DIR"; "$@"; [[ ${#ERRORS[@]} -gt 0 ]]) 2>/dev/null; then
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "  FAIL: $label (expected FAIL)"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

echo "=== lib.sh unit tests ==="

# --- check_file ---
echo "-- check_file --"
touch "$TMP_DIR/exists.md"
assert_pass "existing file" check_file "$TMP_DIR/exists.md"
assert_fail "missing file" check_file "$TMP_DIR/nope.md"

# --- check_pattern ---
echo "-- check_pattern --"
echo "## 코드 품질 8/10" > "$TMP_DIR/pattern.md"
assert_pass "pattern found" check_pattern "$TMP_DIR/pattern.md" "코드 품질" "test"
assert_fail "pattern not found" check_pattern "$TMP_DIR/pattern.md" "NOPE" "test"

# --- check_count ---
echo "-- check_count --"
printf "C1\nC2\nC3\n" > "$TMP_DIR/count.md"
assert_pass "count >= min" check_count "$TMP_DIR/count.md" "C[0-9]+" 3 "test"
assert_fail "count < min" check_count "$TMP_DIR/count.md" "C[0-9]+" 5 "test"

# --- check_count with empty file ---
echo "-- check_count edge: empty file --"
: > "$TMP_DIR/empty.md"
assert_fail "empty file count" check_count "$TMP_DIR/empty.md" "C[0-9]+" 1 "test"

# --- check_no_pattern ---
echo "-- check_no_pattern --"
echo "safe content" > "$TMP_DIR/no_pat.md"
assert_pass "pattern absent" check_no_pattern "$TMP_DIR/no_pat.md" "DANGER" "test"
echo "DANGER here" > "$TMP_DIR/has_pat.md"
assert_fail "pattern present" check_no_pattern "$TMP_DIR/has_pat.md" "DANGER" "test"

# --- check_section_order ---
echo "-- check_section_order --"
printf "## A\n## B\n## C\n" > "$TMP_DIR/order.md"
assert_pass "correct order" check_section_order "$TMP_DIR/order.md" "## A" "## B" "## C"
assert_fail "wrong order" check_section_order "$TMP_DIR/order.md" "## C" "## A"
printf "## A\n" > "$TMP_DIR/partial.md"
assert_fail "missing section" check_section_order "$TMP_DIR/partial.md" "## A" "## B"

# --- check_range ---
echo "-- check_range --"
printf "| 5 |\n| 8 |\n| 10 |\n" > "$TMP_DIR/range.md"
assert_pass "all in range 0-10" check_range "$TMP_DIR/range.md" "\| [0-9]+ \|" 0 10 "test"
printf "| 5 |\n| 11 |\n" > "$TMP_DIR/range_bad.md"
assert_fail "value out of range" check_range "$TMP_DIR/range_bad.md" "\| [0-9]+ \|" 0 10 "test"
assert_fail "empty file range" check_range "$TMP_DIR/empty.md" "\| [0-9]+ \|" 0 10 "test"

# --- check_range boundary ---
echo "-- check_range boundary --"
printf "| 0 |\n| 10 |\n" > "$TMP_DIR/boundary.md"
assert_pass "boundary values 0 and 10" check_range "$TMP_DIR/boundary.md" "\| [0-9]+ \|" 0 10 "test"

# --- Summary ---
echo ""
echo "Results: $PASS_COUNT passed, $FAIL_COUNT failed"
if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi
echo "ALL PASS"
