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
wip_files=("$LOGS_DIR"/*-wip.md)
[[ -e "${wip_files[0]}" ]] || wip_files=()
wip_count=${#wip_files[@]}
if [[ "$wip_count" -lt 5 && "${1:-}" != "--force" ]]; then
  echo "cleanup: ABORT — $wip_count/5 wip files found (expected 5). Use --force to override"
  exit 1
fi

# archive 디렉토리 생성 및 wip 파일 복사
if [[ "$LOOP_NUM" -gt 0 ]]; then
  ARCHIVE_DIR="$LOGS_DIR/archive/loop-$(printf '%03d' "$LOOP_NUM")"
  mkdir -p "$ARCHIVE_DIR"
  [[ ${#wip_files[@]} -gt 0 ]] && cp "${wip_files[@]}" "$ARCHIVE_DIR/"
  # 아카이브 무결성 확인 (실패 시 ABORT — 데이터 무결성 우선)
  arch_files=("$ARCHIVE_DIR"/*-wip.md)
  [[ -e "${arch_files[0]}" ]] || arch_files=()
  archived=${#arch_files[@]}
  if [[ "$archived" -lt 5 ]]; then
    echo "cleanup: ABORT — archived $archived/5 wip files. Archive integrity check failed."
    exit 1
  fi
  echo "cleanup: archived to $ARCHIVE_DIR"
fi

# 정리
rm -f "$LOGS_DIR"/*.bak.md
rm -f "$LOGS_DIR"/*-wip.md

echo "cleanup: done"
