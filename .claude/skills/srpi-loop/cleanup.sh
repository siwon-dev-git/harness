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

# wip 5개 사전 검증 (불완전 상태에서 cleanup 방어)
wip_count=$(ls "$LOGS_DIR"/*-wip.md 2>/dev/null | wc -l | tr -d ' ')
if [[ "$wip_count" -lt 5 && "${1:-}" != "--force" ]]; then
  echo "cleanup: ABORT — $wip_count/5 wip files found (expected 5). Use --force to override"
  exit 1
fi

# archive 디렉토리 생성 및 wip 파일 복사
if [[ "$LOOP_NUM" -gt 0 ]]; then
  ARCHIVE_DIR="$LOGS_DIR/archive/loop-$(printf '%03d' "$LOOP_NUM")"
  mkdir -p "$ARCHIVE_DIR"
  for f in "$LOGS_DIR"/*-wip.md; do
    [[ -f "$f" ]] && cp "$f" "$ARCHIVE_DIR/"
  done
  # 아카이브 무결성 확인
  archived=$(ls "$ARCHIVE_DIR"/*-wip.md 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$archived" -lt 5 ]]; then
    echo "cleanup: WARNING — archived $archived/5 wip files (expected 5)"
  fi
  echo "cleanup: archived to $ARCHIVE_DIR"
fi

# 정리
rm -f "$LOGS_DIR"/*.bak.md
rm -f "$LOGS_DIR"/*-wip.md

echo "cleanup: done"
