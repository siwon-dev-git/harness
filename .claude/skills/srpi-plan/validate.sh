#!/bin/bash
source "$(dirname "$0")/../../scripts/lib.sh"
f="$LOGS_DIR/plan-wip.md"
echo "=== srpi-plan ==="
check_file "$f" || { result; exit; }
check_count "$f" "T[0-9]+" 1 "태스크(T#)"
check_pattern "$f" "대상|Target" "대상 파일"
check_pattern "$f" "변경|Change" "변경 내용"
check_pattern "$f" "검증|Verify|Test" "검증 방법"
check_pattern "$f" "C[0-9]+" "C# 근거"
check_pattern "$f" "실행 순서|순서|Order" "실행 순서"
result
