#!/bin/bash
source "$(dirname "$0")/../../scripts/lib.sh"
f="$LOGS_DIR/quest-wip.md"
echo "=== srpi-evaluate ==="
check_file "$f" || { result; exit; }
check_all_criteria "$f"
check_count "$f" "## .+[0-9]+/10" 5 "점수 5개+"
check_count "$f" "[a-zA-Z0-9_./-]+:[0-9]+" 3 "file:line 근거 3개+"
check_pattern "$f" "요약" "요약"
check_section_order "$f" "## 코드 품질" "## 아키텍처" "## 테스트" "## 보안" "## 성능" "## 요약"
result
