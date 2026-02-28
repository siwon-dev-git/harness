#!/bin/bash
source "$(dirname "$0")/../../scripts/lib.sh"
f="$LOGS_DIR/research-wip.md"
echo "=== srpi-research ==="
check_file "$f" || { result; exit; }
check_count "$f" "C[0-9]+" 1 "주장(C#)"
check_count "$f" "E[0-9]+" 1 "근거(E#)"
check_pattern "$f" "\[FACT\]|\[INFERENCE\]" "근거 태그"
check_pattern "$f" "\[CODE\]|\[DOC\]|\[WEB\]" "출처 타입"
check_pattern "$f" "해결 방안|방안|Solution" "해결 방안"
check_pattern "$f" "임팩트|Impact" "임팩트"
check_pattern "$f" "요약|Summary" "요약"
result
