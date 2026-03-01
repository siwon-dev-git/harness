#!/bin/bash
source "$(dirname "$0")/../../scripts/lib.sh"
echo "=== srpi-verify ==="

F="$LOGS_DIR/verify-wip.md"

# verify-wip.md 존재
check_file "$F"

# 루프 번호 패턴
check_pattern "$F" "^# Verification — Loop [0-9]+" "loop number in title"

# 점수 비교 테이블 (5기준 × Pre/Post, grep -c는 라인 수 기준)
check_count "$F" "[0-9]+/10" 5 "score rows (N/10) >= 5"

# file:line 근거 3개+
check_count "$F" "[a-zA-Z0-9_./-]+:[0-9]+" 3 "file:line evidence >= 3"

# Before/After 변경 전후 근거
check_pattern "$F" "Before:" "before evidence"
check_pattern "$F" "After:" "after evidence"

# 난이도 점수 + 분포
check_pattern "$F" "난이도 점수:" "difficulty score"
check_pattern "$F" "L:[0-9]+ M:[0-9]+ H:[0-9]+" "difficulty distribution"

# Heritage 업데이트 기록
check_pattern "$F" "scoreboard.md:" "scoreboard update record"
check_pattern "$F" "fmea.md:" "fmea update record"

# 다음 루프 권고
check_pattern "$F" "다음 루프 권고" "next loop recommendation"

# Delta 빈 행 방어 (모든 기준에 Delta 값 존재)
check_no_pattern "$F" "\| .+ \| [0-9]+/10 \| [0-9]+/10 \|  \|" "no empty Delta cells"

# scoreboard 행 수 무결성 (append-only 방어)
SB=".claude/heritage/scoreboard.md"
if [[ -f "$SB" ]]; then
  sb_rows=$(grep -cE "^\| [0-9]+" "$SB" 2>/dev/null) || true
  loop_num=$(grep -oE 'Loop [0-9]+' "$F" | head -1 | grep -oE '[0-9]+') || true
  if [[ -n "$sb_rows" && -n "$loop_num" && "$sb_rows" -lt "$loop_num" ]]; then
    err "scoreboard rows ($sb_rows) < loop number ($loop_num) — possible deletion"
  else
    ok "scoreboard integrity (rows=$sb_rows, loop=$loop_num)"
  fi
fi

result
