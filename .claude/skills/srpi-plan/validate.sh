#!/bin/bash
source "$(dirname "$0")/../../scripts/lib.sh"
f="$LOGS_DIR/plan-wip.md"
echo "=== srpi-plan ==="
check_file "$f" || { result; exit; }
check_count "$f" "T[0-9]+" 1 "태스크(T#)"
check_pattern "$f" "대상" "대상 파일"
check_pattern "$f" "변경" "변경 내용"
check_pattern "$f" "검증" "검증 방법"
check_pattern "$f" "C[0-9]+" "C# 근거"
check_pattern "$f" "실행 순서|순서" "실행 순서"
check_pattern "$f" "난이도 분포" "난이도 분포"
check_pattern "$f" "난이도 점수" "난이도 점수"
check_count "$f" "[LMH]: [0-9]+개" 3 "난이도 L/M/H 항목"
check_difficulty_sum "$f" "난이도 합 == 태스크 수"
result
