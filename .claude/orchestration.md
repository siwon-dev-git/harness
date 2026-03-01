# Orchestration

## Skill Map

| Skill | Input | Output | Verification |
|-------|-------|--------|-------------|
| `/srpi-evaluate` | 코드베이스 | `logs/quest-wip.md` | `validate.sh` — 5기준 점수 + file:line 근거 |
| `/srpi-research` | `logs/quest-wip.md` | `logs/research-wip.md` | `validate.sh` — C#-E# 매핑 + 반증 2회+ |
| `/srpi-plan` | `logs/research-wip.md` | `logs/plan-wip.md` | `validate.sh` — T# 태스크 + 실행 순서 |
| `/srpi-implement` | `logs/plan-wip.md` | `logs/impl-wip.md` | `validate.sh` — 태스크 상태 + 성공률 |
| `/srpi-verify` | `logs/impl-wip.md` | `logs/verify-wip.md` | `validate.sh` — 점수 delta + 난이도 감사 + heritage 업데이트 |
| `/srpi-loop` | 코드베이스 | 위 5단계 순차 | `validate.sh` + `cleanup.sh` |

## Rules

- 순차 강제: 이전 단계 validate PASS 없이 다음 단계 진입 불가
- validate 실패 시: 해당 단계 내에서 수정 후 재검증 (최대 3회)
- 스코프 제한: 단계당 100k 토큰 이내 권장

## Mutation Safety

constitution.md 수정 시도 → 무조건 REJECT.

보호 파일 수정 시 검증:
1. 기존 원칙(Core Principles) 보존 여부
2. Hard Constraints 위반 여부
3. 보호 파일 목록과의 충돌 여부

Risk High 이상 → 사용자 승인 필요.
