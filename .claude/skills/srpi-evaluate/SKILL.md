---
name: srpi-evaluate
description: 코드베이스를 5개 기준으로 평가하여 logs/quest-wip.md를 생성한다.
disable-model-invocation: true
---

코드베이스를 [평가 기준](../../context/conventions.md)으로 평가하여 [template.md](template.md) 형식으로 `logs/quest-wip.md`에 기록한다.

기준별로 코드 탐색 → file:line 근거와 함께 점수 판정 → 즉시 기록.

완료 후 `bash .claude/skills/srpi-evaluate/validate.sh` 실행.
