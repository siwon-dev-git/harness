#!/bin/bash
# SRPI 루프 상태 감지: 각 단계의 wip 파일 존재 여부 출력
set -euo pipefail

LOGS_DIR="${1:-logs}"
SCOREBOARD=".claude/heritage/scoreboard.md"

# 현재 루프 번호
loop_num=0
if [[ -f "$SCOREBOARD" ]]; then
  loop_num=$(grep -cE '^\| [0-9]' "$SCOREBOARD" 2>/dev/null) || true
fi
echo "현재 루프: $((loop_num + 1))"
echo ""

# 단계별 상태 감지
declare -a STAGES=("quest" "research" "plan" "impl" "verify")
declare -a LABELS=("evaluate" "research" "plan" "implement" "verify")
first_missing=""

for i in "${!STAGES[@]}"; do
  stage="${STAGES[$i]}"
  label="${LABELS[$i]}"
  wip="$LOGS_DIR/${stage}-wip.md"
  if [[ -f "$wip" ]]; then
    echo "  ✓ ${label} — ${wip}"
  else
    echo "  ✗ ${label} — missing"
    if [[ -z "$first_missing" ]]; then
      first_missing="$label"
    fi
  fi
done

echo ""
if [[ -n "$first_missing" ]]; then
  echo "다음 단계: /srpi-${first_missing}"
else
  echo "모든 단계 완료. cleanup.sh 실행 가능"
fi
