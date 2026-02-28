#!/bin/bash
source "$(dirname "$0")/../../scripts/lib.sh"
f="$LOGS_DIR/impl-wip.md"
echo "=== srpi-implement ==="
check_file "$f" || { result; exit; }
check_count "$f" "T[0-9]+" 1 "태스크(T#)"
check_pattern "$f" "✅|❌|⏭|PASS|FAIL|SKIP" "상태 표기"
check_pattern "$f" "변경|Changed" "변경 기록"
check_pattern "$f" "검증|Verify" "검증 결과"
check_pattern "$f" "요약|Summary" "요약"
check_pattern "$f" "[1-9][0-9]*/[1-9][0-9]*" "성공률 (0/0 제외)"
result
