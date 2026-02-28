---
name: srpi-implement
description: 계획 순서대로 구현하고 검증하여 logs/impl-wip.md를 생성한다. 커밋하지 않음.
disable-model-invocation: true
---

`logs/plan-wip.md`의 태스크를 순서대로 구현·검증하여 [template.md](template.md) 형식으로 `logs/impl-wip.md`에 기록한다.

검증 실패 시 `git checkout -- <file>`로 롤백. 선행 실패 시 후속은 SKIP. 커밋 금지.

완료 후 `bash .claude/skills/srpi-implement/validate.sh` 실행.
