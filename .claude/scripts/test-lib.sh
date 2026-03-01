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

# --- check_scoreboard_delta ---
echo "-- check_scoreboard_delta --"
# Normal case: small delta
cat > "$TMP_DIR/sb_ok.md" <<'SB'
| 0 | 2026-03-01 | 6 | 7 | 6 | 6 | 6 | 6.4 | - | - | - | - | - |
| 1 | 2026-03-01 | 7 | 8 | 7 | 7 | 7 | 7.2 | +0.8 | 8 | 8/8 | 1.5 | PASS |
SB
assert_pass "small delta ok" check_scoreboard_delta "$TMP_DIR/sb_ok.md" 2 "test"

# Big drop: avg drops by 3
cat > "$TMP_DIR/sb_drop.md" <<'SB'
| 0 | 2026-03-01 | 8 | 8 | 8 | 8 | 8 | 8.0 | - | - | - | - | - |
| 1 | 2026-03-01 | 5 | 5 | 5 | 5 | 5 | 5.0 | -3.0 | 8 | 8/8 | 1.5 | PASS |
SB
assert_fail "big drop detected" check_scoreboard_delta "$TMP_DIR/sb_drop.md" 2 "test"

# Single row: skip (not enough data)
cat > "$TMP_DIR/sb_one.md" <<'SB'
| 0 | 2026-03-01 | 6 | 7 | 6 | 6 | 6 | 6.4 | - | - | - | - | - |
SB
assert_pass "single row skip" check_scoreboard_delta "$TMP_DIR/sb_one.md" 2 "test"

# --- parse-scores.sh ---
echo "-- parse-scores.sh --"

# Normal quest file
cat > "$TMP_DIR/quest_ok.md" <<'Q'
## 코드 품질 (8/10)
evidence
## 아키텍처 (7/10)
evidence
## 테스트 (8/10)
evidence
## 보안 (6/10)
evidence
## 성능 (7/10)
evidence
## 요약
Q
output=$(bash "$SCRIPT_DIR/parse-scores.sh" "$TMP_DIR/quest_ok.md" 2>/dev/null)
if echo "$output" | grep -q "7.2/10"; then
  echo "  PASS: parse-scores normal"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo "  FAIL: parse-scores normal (expected avg 7.2)"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Missing file
if bash "$SCRIPT_DIR/parse-scores.sh" "$TMP_DIR/nope.md" >/dev/null 2>&1; then
  echo "  FAIL: parse-scores missing file (expected error)"
  FAIL_COUNT=$((FAIL_COUNT + 1))
else
  echo "  PASS: parse-scores missing file"
  PASS_COUNT=$((PASS_COUNT + 1))
fi

# --- loop-status.sh ---
echo "-- loop-status.sh --"

# No wip files
mkdir -p "$TMP_DIR/empty_logs"
output=$(bash "$SCRIPT_DIR/loop-status.sh" "$TMP_DIR/empty_logs" 2>/dev/null)
if echo "$output" | grep -q "evaluate — missing"; then
  echo "  PASS: loop-status no wip"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo "  FAIL: loop-status no wip (expected evaluate missing)"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Some wip files
mkdir -p "$TMP_DIR/partial_logs"
touch "$TMP_DIR/partial_logs/quest-wip.md" "$TMP_DIR/partial_logs/research-wip.md"
output=$(bash "$SCRIPT_DIR/loop-status.sh" "$TMP_DIR/partial_logs" 2>/dev/null)
if echo "$output" | grep -q "plan — missing"; then
  echo "  PASS: loop-status partial wip"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo "  FAIL: loop-status partial wip (expected plan missing)"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# All wip files
mkdir -p "$TMP_DIR/full_logs"
for w in quest research plan impl verify; do touch "$TMP_DIR/full_logs/${w}-wip.md"; done
output=$(bash "$SCRIPT_DIR/loop-status.sh" "$TMP_DIR/full_logs" 2>/dev/null)
if echo "$output" | grep -q "cleanup.sh"; then
  echo "  PASS: loop-status all complete"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo "  FAIL: loop-status all complete (expected cleanup message)"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# --- result() output format ---
echo "-- result() format --"

# PASS case with timing
output=$(source "$SCRIPT_DIR/lib.sh"; LOGS_DIR="$TMP_DIR"; result 2>&1) || true
if echo "$output" | grep -qE "PASS \([0-9]+s\)"; then
  echo "  PASS: result PASS format"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo "  FAIL: result PASS format (expected 'PASS (Ns)')"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# FAIL case with timing
output=$(source "$SCRIPT_DIR/lib.sh"; LOGS_DIR="$TMP_DIR"; ERRORS+=("test error"); result 2>&1) || true
if echo "$output" | grep -qE "FAIL: 1 errors \([0-9]+s\)"; then
  echo "  PASS: result FAIL format"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo "  FAIL: result FAIL format (expected 'FAIL: 1 errors (Ns)')"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# --- check_all_criteria ---
echo "-- check_all_criteria --"

# Valid quest file with all 5 criteria
cat > "$TMP_DIR/criteria_ok.md" <<'Q'
## 코드 품질 (8/10)
evidence
## 아키텍처 (7/10)
evidence
## 테스트 (8/10)
evidence
## 보안 (6/10)
evidence
## 성능 (7/10)
evidence
Q
assert_pass "all 5 criteria present" check_all_criteria "$TMP_DIR/criteria_ok.md"

# Missing criteria
cat > "$TMP_DIR/criteria_bad.md" <<'Q'
## 코드 품질 (8/10)
## 아키텍처 (7/10)
Q
assert_fail "missing 3 criteria" check_all_criteria "$TMP_DIR/criteria_bad.md"

# --- check_difficulty_sum ---
echo "-- check_difficulty_sum --"

# Correct sum: 1+1+1 = 3 tasks
cat > "$TMP_DIR/diff_ok.md" <<'D'
## T1: task1
## T2: task2
## T3: task3
L: 1개
M: 1개
H: 1개
D
assert_pass "sum matches (3=3)" check_difficulty_sum "$TMP_DIR/diff_ok.md" "test"

# Mismatch: 2+1+0 = 3 but only 1 task
cat > "$TMP_DIR/diff_bad.md" <<'D'
## T1: only task
L: 2개
M: 1개
H: 0개
D
assert_fail "sum mismatch (3!=1)" check_difficulty_sum "$TMP_DIR/diff_bad.md" "test"

# Two-digit numbers: 10+5+2 = 17 tasks
cat > "$TMP_DIR/diff_big.md" <<'D'
## T1: a
## T2: b
## T3: c
## T4: d
## T5: e
## T6: f
## T7: g
## T8: h
## T9: i
## T10: j
## T11: k
## T12: l
## T13: m
## T14: n
## T15: o
## T16: p
## T17: q
L: 10개
M: 5개
H: 2개
D
assert_pass "two-digit count (10+5+2=17)" check_difficulty_sum "$TMP_DIR/diff_big.md" "test"

# --- parse-scores.sh --strict ---
echo "-- parse-scores.sh --strict --"

# Strict mode with missing criteria
cat > "$TMP_DIR/strict_bad.md" <<'Q'
## 코드 품질 (8/10)
evidence
## 아키텍처 (7/10)
evidence
Q
if bash "$SCRIPT_DIR/parse-scores.sh" --strict "$TMP_DIR/strict_bad.md" >/dev/null 2>&1; then
  echo "  FAIL: strict mode missing criteria (expected error)"
  FAIL_COUNT=$((FAIL_COUNT + 1))
else
  echo "  PASS: strict mode missing criteria"
  PASS_COUNT=$((PASS_COUNT + 1))
fi

# Strict mode with all criteria
if bash "$SCRIPT_DIR/parse-scores.sh" --strict "$TMP_DIR/criteria_ok.md" >/dev/null 2>&1; then
  echo "  PASS: strict mode all criteria"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo "  FAIL: strict mode all criteria (expected success)"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# --- Summary ---
echo ""
echo "Results: $PASS_COUNT passed, $FAIL_COUNT failed"
if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi
echo "ALL PASS"
