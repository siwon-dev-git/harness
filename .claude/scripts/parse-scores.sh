#!/bin/bash
# quest-wip.md에서 5기준 점수 추출 + 평균 계산
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

# 5기준 점수 추출 (N/10 형식)
declare -a CRITERIA=("코드 품질" "아키텍처" "테스트" "보안" "성능")
declare -a SCORES=()
total=0

for c in "${CRITERIA[@]}"; do
  score=$(grep -E "## ${c}.*[0-9]+/10" "$FILE" | grep -oE '[0-9]+/10' | head -1 | cut -d/ -f1) || true
  if [[ -z "$score" ]]; then
    if $STRICT; then
      echo "ERROR: $c score not found" >&2
      exit 1
    fi
    echo "WARNING: $c score not found" >&2
    score=0
  fi
  SCORES+=("$score")
  total=$((total + score))
  printf "%-12s %s/10\n" "$c" "$score"
done

# 평균 (소수점 1자리)
avg=$(echo "scale=1; $total / 5" | bc)
printf "%-12s %s/10\n" "평균" "$avg"
