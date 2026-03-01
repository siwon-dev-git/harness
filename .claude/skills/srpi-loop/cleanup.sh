#!/bin/bash
# 루프 완료 후 archive → wip·bak 파일 정리
set -euo pipefail

LOGS_DIR="logs"
SCOREBOARD=".claude/heritage/scoreboard.md"

# 루프 번호 결정: scoreboard 데이터 행 수
LOOP_NUM=0
if [[ -f "$SCOREBOARD" ]]; then
  LOOP_NUM=$(grep -cE '^\| [0-9]' "$SCOREBOARD" 2>/dev/null) || true
fi

# archive 디렉토리 생성 및 wip 파일 복사
if [[ "$LOOP_NUM" -gt 0 ]]; then
  ARCHIVE_DIR="$LOGS_DIR/archive/loop-$(printf '%03d' "$LOOP_NUM")"
  mkdir -p "$ARCHIVE_DIR"
  for f in "$LOGS_DIR"/*-wip.md; do
    [[ -f "$f" ]] && cp "$f" "$ARCHIVE_DIR/"
  done
  echo "cleanup: archived to $ARCHIVE_DIR"
fi

# 정리
rm -f "$LOGS_DIR"/*.bak.md
rm -f "$LOGS_DIR"/*-wip.md

echo "cleanup: done"
