#!/bin/bash
source "$(dirname "$0")/../../scripts/lib.sh"
f="$LOGS_DIR/quest-wip.md"
echo "=== srpi-evaluate ==="
check_file "$f" || { result; exit; }
check_pattern "$f" "## 코드 품질.*[0-9]+/10|## Code Quality.*[0-9]+/10" "코드 품질 섹션+점수"
check_pattern "$f" "## 아키텍처.*[0-9]+/10|## Architecture.*[0-9]+/10" "아키텍처 섹션+점수"
check_pattern "$f" "## 테스트.*[0-9]+/10|## Test.*[0-9]+/10" "테스트 섹션+점수"
check_pattern "$f" "## 보안.*[0-9]+/10|## Security.*[0-9]+/10" "보안 섹션+점수"
check_pattern "$f" "## 성능.*[0-9]+/10|## Performance.*[0-9]+/10" "성능 섹션+점수"
check_count "$f" "## .+[0-9]+/10" 5 "점수 5개+"
check_count "$f" "[a-zA-Z0-9_./-]+:[0-9]+" 3 "file:line 근거 3개+"
check_pattern "$f" "요약|Summary" "요약"
result
