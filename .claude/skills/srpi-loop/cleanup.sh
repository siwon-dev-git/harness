#!/bin/bash
# 루프 완료 후 wip·bak 파일 정리
set -euo pipefail

LOGS_DIR="logs"

rm -f "$LOGS_DIR"/*.bak.md
rm -f "$LOGS_DIR"/*-wip.md

echo "cleanup: done"
