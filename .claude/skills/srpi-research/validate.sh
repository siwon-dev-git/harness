#!/bin/bash
source "$(dirname "$0")/../../scripts/lib.sh"
f="$LOGS_DIR/research-wip.md"
echo "=== srpi-research ==="
check_file "$f" || { result; exit; }
check_count "$f" "C[0-9]+" 3 "주장(C#) 3개+"
check_count "$f" "E[0-9]+" 3 "근거(E#) 3개+"
check_pattern "$f" "\[FACT\]|\[INFERENCE\]" "근거 태그"
check_pattern "$f" "\[CODE\]|\[DOC\]|\[WEB\]" "출처 타입"
check_pattern "$f" "해결 방안|방안" "해결 방안"
check_pattern "$f" "임팩트" "임팩트"
check_pattern "$f" "요약" "요약"
check_count "$f" "Counter-hypothesis" 2 "반증 시도(Counter-hypothesis)"
result
