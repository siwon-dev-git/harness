#!/bin/bash
# SRPI 전체 테스트 통합 실행
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== SRPI Test Suite ==="
echo ""

bash "$SCRIPT_DIR/test-lib.sh"
echo ""
bash "$SCRIPT_DIR/test-validators.sh"

echo ""
echo "=== All tests passed ==="
