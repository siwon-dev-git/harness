# CLAUDE.md

## Project Overview

SRPI (Self-improvement Research Plan Implement) 하네스 — Claude Code 스킬을 활용한 자기개선 루프 시스템.

코드베이스를 자동으로 평가하고, 문제를 분석하고, 개선 계획을 세우고, 구현하는 사이클을 반복한다.

## SRPI Loop

```
/srpi-evaluate → /srpi-research → /srpi-plan → /srpi-implement
       ↑                                              |
       └──────────────────────────────────────────────┘
```

| 스킬 | 입력 | 출력 |
|------|------|------|
| `/srpi-evaluate` | 코드베이스 | `logs/quest-wip.md` |
| `/srpi-research` | `logs/quest-wip.md` | `logs/research-wip.md` |
| `/srpi-plan` | `logs/research-wip.md` | `logs/plan-wip.md` |
| `/srpi-implement` | `logs/plan-wip.md` | `logs/impl-wip.md` |
| `/srpi-loop` | 코드베이스 | 위 4단계 순차 실행 |

## Conventions

- 각 스테이지의 결과는 `logs/` 디렉토리에 `-wip.md`로 저장
- 다음 스테이지는 이전 스테이지의 출력을 입력으로 사용
- `/srpi-implement`는 커밋하지 않음 — 사용자가 직접 확인 후 커밋
