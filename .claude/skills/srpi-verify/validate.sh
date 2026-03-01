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

result
