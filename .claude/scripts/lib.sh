#!/bin/bash
# SRPI 검증 공통 함수
set -euo pipefail

LOGS_DIR="logs"
ERRORS=()

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

result() {
  echo ""
  if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo "FAIL: ${#ERRORS[@]} errors"
    printf '  %s\n' "${ERRORS[@]}"
    exit 1
  fi
  echo "PASS"
}
