#!/bin/bash
# validate.sh 네거티브 테스트: 잘못된 wip 파일로 FAIL 확인
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

PASS_COUNT=0
FAIL_COUNT=0

# Helper: run validator expecting PASS
expect_pass() {
  local label="$1" validator="$2"
  if (cd "$TMP_DIR" && bash "$PROJECT_DIR/.claude/skills/$validator/validate.sh") >/dev/null 2>&1; then
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "  FAIL: $label (expected PASS, got FAIL)"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

# Helper: run validator expecting FAIL
expect_fail() {
  local label="$1" validator="$2"
  if (cd "$TMP_DIR" && bash "$PROJECT_DIR/.claude/skills/$validator/validate.sh") >/dev/null 2>&1; then
    echo "  FAIL: $label (expected FAIL, got PASS)"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  else
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
  fi
}

echo "=== validator negative tests ==="

# --- srpi-evaluate ---
echo "-- srpi-evaluate --"

# Missing file → FAIL
rm -f "$TMP_DIR/logs/quest-wip.md"
expect_fail "evaluate: missing file" "srpi-evaluate"

# Valid file → PASS
mkdir -p "$TMP_DIR/logs"
cat > "$TMP_DIR/logs/quest-wip.md" <<'WIP'
# Evaluation
## 코드 품질 (8/10)
- `lib.sh:1` — evidence
## 아키텍처 (8/10)
- `lib.sh:2` — evidence
## 테스트 (7/10)
- `lib.sh:3` — evidence
## 보안 (7/10)
- `lib.sh:4` — evidence
## 성능 (7/10)
- `lib.sh:5` — evidence
## 요약
| 기준 | 점수 |
WIP
expect_pass "evaluate: valid file" "srpi-evaluate"

# Missing score → FAIL
cat > "$TMP_DIR/logs/quest-wip.md" <<'WIP'
# Evaluation
## 코드 품질
no score here
## 아키텍처 (8/10)
## 테스트 (7/10)
## 보안 (7/10)
## 성능 (7/10)
## 요약
WIP
expect_fail "evaluate: missing score" "srpi-evaluate"

# --- srpi-research ---
echo "-- srpi-research --"

# Missing file → FAIL
rm -f "$TMP_DIR/logs/research-wip.md"
expect_fail "research: missing file" "srpi-research"

# Valid file → PASS
cat > "$TMP_DIR/logs/research-wip.md" <<'WIP'
# Research
C1: claim ← E1: [CODE] `file:1` [FACT]
Counter-hypothesis: test1
Counter-hypothesis: test2
C2: claim ← E2: [CODE] `file:2` [FACT]
C3: claim ← E3: [DOC] url [INFERENCE]
해결 방안 — 임팩트: H
요약
WIP
expect_pass "research: valid file" "srpi-research"

# Missing claims → FAIL
cat > "$TMP_DIR/logs/research-wip.md" <<'WIP'
# Research
no claims here
요약
WIP
expect_fail "research: no claims" "srpi-research"

# --- srpi-plan ---
echo "-- srpi-plan --"

# Missing file → FAIL
rm -f "$TMP_DIR/logs/plan-wip.md"
expect_fail "plan: missing file" "srpi-plan"

# Valid file → PASS
cat > "$TMP_DIR/logs/plan-wip.md" <<'WIP'
# Plan
## T1: task — 난이도: M
- 근거: C1-E1
- 대상: file
- 변경: change
- 검증: verify
실행 순서: T1
난이도 분포: L:1 M:1 H:0
난이도 점수: 1.5
L: 1개
M: 1개
H: 0개
WIP
expect_pass "plan: valid file" "srpi-plan"

# Missing task → FAIL
cat > "$TMP_DIR/logs/plan-wip.md" <<'WIP'
# Plan
no tasks
WIP
expect_fail "plan: no tasks" "srpi-plan"

# --- Summary ---
echo ""
echo "Results: $PASS_COUNT passed, $FAIL_COUNT failed"
if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi
echo "ALL PASS"
