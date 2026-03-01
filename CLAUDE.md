# CLAUDE.md

## Project Overview

SRPI (Self-improvement Research Plan Implement) 하네스 — Claude Code 스킬을 활용한 자기개선 루프 시스템.

코드베이스를 자동으로 평가하고, 문제를 분석하고, 개선 계획을 세우고, 구현하는 사이클을 반복한다.

## SRPI Loop

```
/srpi-evaluate → /srpi-research → /srpi-plan → /srpi-implement → /srpi-verify
       ↑                                                              |
       └──────────────────────────────────────────────────────────────┘
```

| 스킬 | 입력 | 출력 |
|------|------|------|
| `/srpi-evaluate` | 코드베이스 | `logs/quest-wip.md` |
| `/srpi-research` | `logs/quest-wip.md` | `logs/research-wip.md` |
| `/srpi-plan` | `logs/research-wip.md` | `logs/plan-wip.md` |
| `/srpi-implement` | `logs/plan-wip.md` | `logs/impl-wip.md` |
| `/srpi-verify` | `logs/impl-wip.md` | `logs/verify-wip.md` |
| `/srpi-loop` | 코드베이스 | 위 5단계 순차 실행 |

## Heritage

루프마다 축적되는 경험 기록:
- `.claude/heritage/adr.md` — 설계 결정 (추가만 허용)
- `.claude/heritage/fmea.md` — 실패 패턴: Detect/Fix/Prevent (추가만 허용)
- `.claude/heritage/scoreboard.md` — 루프별 점수 추적 (추가만 허용)
- `logs/archive/loop-NNN/` — 루프별 wip 파일 보존

## Conventions

- 각 스테이지의 결과는 `logs/` 디렉토리에 `-wip.md`로 저장
- 다음 스테이지는 이전 스테이지의 출력을 입력으로 사용
- `/srpi-implement`는 커밋하지 않음 — 사용자가 직접 확인 후 커밋
- 단계 간 `/compact` 권장 — 컨텍스트 누적 방지
