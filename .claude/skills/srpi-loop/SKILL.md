---
name: srpi-loop
description: SRPI 5단계를 순차 실행한다.
disable-model-invocation: true
---

## 상태 감지

아래 명령으로 각 단계의 완료 여부를 확인한다:

```bash
for f in quest research plan impl verify; do
  [ -f "logs/${f}-wip.md" ] && echo "${f}: exists" || echo "${f}: missing"
done
```

missing인 단계부터 순서대로 실행: evaluate → research → plan → implement → **verify**.
각 단계는 해당 스킬의 SKILL.md를 읽고 절차를 수행.
단계 완료 후 validate.sh 통과해야 다음으로 진행.

단계 간 `/compact` 권장 — 컨텍스트 누적 방지.

5단계 모두 완료 후 `bash .claude/skills/srpi-loop/cleanup.sh` 실행.
