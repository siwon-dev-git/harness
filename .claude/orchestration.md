# Orchestration

## Skill Map

| Skill | Input | Output | Verification |
|-------|-------|--------|-------------|
| `/srpi-evaluate` | 코드베이스 | `logs/quest-wip.md` | `validate.sh` — 5기준 점수 + file:line 근거 |
| `/srpi-research` | `logs/quest-wip.md` | `logs/research-wip.md` | `validate.sh` — C#-E# 매핑 + 반증 2회+ |
| `/srpi-plan` | `logs/research-wip.md` | `logs/plan-wip.md` | `validate.sh` — T# 태스크 + 실행 순서 |
| `/srpi-implement` | `logs/plan-wip.md` | `logs/impl-wip.md` | `validate.sh` — 태스크 상태 + 성공률 |
| `/srpi-verify` | `logs/impl-wip.md` | `logs/verify-wip.md` | `validate.sh` — 점수 delta + 난이도 감사 + heritage 업데이트 |
| `/srpi-loop` | 코드베이스 | 위 5단계 순차 | `validate.sh` (5단계) + `cleanup.sh` (wip 아카이브/제거) |

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

## Risk 분류

| Risk | 기준 | 대상 파일 | 조치 |
|------|------|----------|------|
| Risk High | 불변 원칙 위반 가능 | `constitution.md` | REJECT (수정 불가) |
| Risk Medium | 보호 파일 구조 변경 | `orchestration.md`, `conventions.md`, `SKILL.md` | Mutation Safety 3단계 검증 |
| Risk Low | 보호 파일 내용 추가 | `adr.md`, `fmea.md`, `scoreboard.md` | append-only 준수 확인 |

Risk Medium 이상 → 사용자 승인 필요.

## References

- `context/conventions.md` — C#-E# 형식, 점수 기준, 난이도 거버넌스
- `context/methodology.md` — 반증 루프, 근거 계층 (L1/L2/L3)
- `heritage/` — ADR(결정), FMEA(실패 패턴), Scoreboard(점수 추적)
- `scripts/lib.sh` — 검증 공통 함수 (check_*)
- `scripts/parse-scores.sh` — Pre-score 자동 파싱
- `scripts/loop-status.sh` — 루프 상태 감지
