#!/bin/bash
source "$(dirname "$0")/../../scripts/lib.sh"
echo "=== srpi-verify ==="

f="$LOGS_DIR/verify-wip.md"

# verify-wip.md 존재
check_file "$f"

# 루프 번호 패턴
check_pattern "$f" "^# Verification — Loop [0-9]+" "loop number in title"

# 점수 비교 테이블 (5기준 × Pre/Post, grep -c는 라인 수 기준)
check_count "$f" "[0-9]+/10" 5 "score rows (N/10) >= 5"

# file:line 근거 3개+
check_count "$f" "[a-zA-Z0-9_./-]+:[0-9]+" 3 "file:line evidence >= 3"

# Before/After 변경 전후 근거
check_pattern "$f" "Before:" "before evidence"
check_pattern "$f" "After:" "after evidence"

# 난이도 점수 + 분포
check_pattern "$f" "난이도 점수:" "difficulty score"
check_pattern "$f" "L:[0-9]+ M:[0-9]+ H:[0-9]+" "difficulty distribution"

# Heritage 업데이트 기록
check_pattern "$f" "scoreboard.md:" "scoreboard update record"
check_pattern "$f" "fmea.md:" "fmea update record"

# 다음 루프 권고
check_pattern "$f" "다음 루프 권고" "next loop recommendation"

# Delta 빈 행 방어 (모든 기준에 Delta 값 존재)
check_no_pattern "$f" "\| .+ \| [0-9]+/10 \| [0-9]+/10 \|  \|" "no empty Delta cells"

# scoreboard 점수 범위 검증 (0-10)
SB=".claude/heritage/scoreboard.md"
if [[ -f "$SB" ]]; then
  check_range "$SB" "\| [0-9]+ \|" 0 10 "scoreboard scores in 0-10 range"
fi

# scoreboard 행 수 무결성 (append-only 방어)
if [[ -f "$SB" ]]; then
  sb_rows=$(grep -cE "^\| [0-9]+" "$SB" 2>/dev/null) || true
  loop_num=$(grep -oE 'Loop [0-9]+' "$f" | head -1 | grep -oE '[0-9]+') || true
  if [[ -n "$sb_rows" && -n "$loop_num" && "$sb_rows" -lt "$loop_num" ]]; then
    err "scoreboard rows ($sb_rows) < loop number ($loop_num) — possible deletion"
  else
    ok "scoreboard integrity (rows=$sb_rows, loop=$loop_num)"
  fi
fi

# scoreboard 점수 급락 감지 (max 2.0 drop)
if [[ -f "$SB" ]]; then
  check_scoreboard_delta "$SB" 2 "scoreboard avg drop <= 2.0"
fi

# fmea 행 수 무결성 (append-only 방어)
FM=".claude/heritage/fmea.md"
if [[ -f "$FM" ]]; then
  fm_patterns=$(grep -cE '^\- \*\*' "$FM" 2>/dev/null) || true
  if [[ -n "$fm_patterns" && "$fm_patterns" -gt 0 ]]; then
    ok "fmea integrity (patterns=$fm_patterns)"
  else
    err "fmea has no patterns — possible deletion"
  fi
fi

result
