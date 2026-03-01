#!/bin/bash
# SRPI 검증 공통 함수
set -euo pipefail

LOGS_DIR="logs"
ERRORS=()
_LIB_START=$(date +%s)

err() { ERRORS+=("FAIL: $1"); }
ok()  { echo "  OK: $1"; }

check_file() {
  [[ -f "$1" ]] && ok "$1 exists" || { err "$1 missing"; return 1; }
}

check_pattern() {
  grep -qE "$2" "$1" 2>/dev/null && ok "$3" || err "$3 -- pattern not found"
}

check_count() {
  local c=0
  c=$(grep -cE "$2" "$1" 2>/dev/null) || true
  [[ "$c" -ge "$3" ]] && ok "$4 ($c)" || err "$4 -- need $3, found $c"
}

check_no_pattern() {
  grep -qE "$2" "$1" 2>/dev/null && err "$3 -- pattern should NOT exist" || ok "$3"
}

check_section_order() {
  local file="$1"; shift
  local prev_line=0
  for section in "$@"; do
    local line
    line=$(grep -nE "$section" "$file" 2>/dev/null | head -1 | cut -d: -f1) || true
    if [[ -z "$line" ]]; then
      err "section '$section' not found in $file"
      return
    fi
    if [[ "$line" -le "$prev_line" ]]; then
      err "section '$section' (L$line) out of order (expected after L$prev_line)"
      return
    fi
    prev_line="$line"
  done
  ok "section order correct"
}

check_range() {
  # Usage: check_range <file> <grep_pattern> <min> <max> <label>
  # Extracts all numbers matching pattern and verifies each is within [min, max]
  local file="$1" pattern="$2" min="$3" max="$4" label="$5"
  local nums
  nums=$(grep -oE "$pattern" "$file" 2>/dev/null | grep -oE '[0-9]+') || true
  if [[ -z "$nums" ]]; then
    err "$label -- no numbers found"
    return
  fi
  local out_of_range=0
  while IFS= read -r n; do
    if [[ "$n" -lt "$min" || "$n" -gt "$max" ]]; then
      out_of_range=$((out_of_range + 1))
    fi
  done <<< "$nums"
  if [[ "$out_of_range" -gt 0 ]]; then
    err "$label -- $out_of_range values outside [$min, $max]"
  else
    ok "$label"
  fi
}

result() {
  local elapsed=$(( $(date +%s) - _LIB_START ))
  echo ""
  if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo "FAIL: ${#ERRORS[@]} errors (${elapsed}s)"
    printf '  %s\n' "${ERRORS[@]}"
    exit 1
  fi
  echo "PASS (${elapsed}s)"
}
