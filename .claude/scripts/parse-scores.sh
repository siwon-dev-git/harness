#!/bin/bash
# quest-wip.md에서 5기준 점수 추출 + 평균 계산 (단일 패스)
set -euo pipefail

STRICT=false
if [[ "${1:-}" == "--strict" ]]; then
  STRICT=true
  shift
fi
FILE="${1:-logs/quest-wip.md}"

if [[ ! -f "$FILE" ]]; then
  echo "ERROR: $FILE not found" >&2
  exit 1
fi

# lib.sh에서 SRPI_CRITERIA 공유 배열 참조
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib.sh" 2>/dev/null || { echo "ERROR: lib.sh not found at $SCRIPT_DIR/lib.sh" >&2; exit 1; }

# 단일 awk 패스로 모든 기준 점수 추출 → 메모리에 보관
SCORE_DATA=$(awk -F'[(/]' '/^## .+[0-9]+\/10/{gsub(/^## /,"",$1); gsub(/ *$/,"",$1); print $1 "=" $(NF-1)+0}' "$FILE")

total=0
count=0
for c in "${SRPI_CRITERIA[@]}"; do
  score=$(echo "$SCORE_DATA" | grep -F "$c=" | head -1 | cut -d= -f2) || true
  if [[ -z "$score" ]]; then
    if $STRICT; then
      echo "ERROR: $c score not found" >&2
      exit 1
    fi
    echo "WARNING: $c score not found" >&2
    score=0
  fi
  total=$((total + score))
  count=$((count + 1))
  printf "%-12s %s/10\n" "$c" "$score"
done

# 평균 (소수점 1자리)
avg=$(echo "scale=1; $total / $count" | bc)
printf "%-12s %s/10\n" "평균" "$avg"
