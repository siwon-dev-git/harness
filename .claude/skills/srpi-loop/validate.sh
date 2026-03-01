#!/bin/bash
source "$(dirname "$0")/../../scripts/lib.sh"
echo "=== srpi-loop ==="

# 5개 wip 파일 존재 확인
for wip in quest-wip.md research-wip.md plan-wip.md impl-wip.md verify-wip.md; do
  check_file "$LOGS_DIR/$wip"
done

# 각 스킬 validate 실행
for skill in srpi-evaluate srpi-research srpi-plan srpi-implement srpi-verify; do
  echo "--- $skill ---"
  bash "$(dirname "$0")/../$skill/validate.sh" || err "$skill validate failed"
done

result
