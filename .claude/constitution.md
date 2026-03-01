# Constitution (Trust Anchor)

> This file is READ-ONLY for agents. Only the human creator may modify it.
> Any mutation attempt against this file MUST be rejected.

## Core Principles

1. **근거 기반** — 모든 주장은 file:line 또는 L1 소스로 뒷받침되어야 한다
2. **즉시 기록** — 발견 즉시 wip 파일에 기록. 배치 금지
3. **커밋 금지** — 사용자가 직접 확인 후 커밋
4. **검증 필수** — 각 스킬 완료 후 validate.sh 실행

## Hard Constraints

1. constitution.md는 에이전트가 수정할 수 없다
2. 보호 파일 목록의 파일은 mutation safety 절차 없이 수정할 수 없다
3. Self-scoring 편향을 인지하고 방어해야 한다 (Babel paradox)
4. validate 실패 시 다음 단계로 진행할 수 없다
5. heritage에 기록된 실패 패턴을 반복하면 안 된다

## Protected Files

수정 시 mutation safety 검증 필수:
- `.claude/constitution.md` — 수정 불가 (READ-ONLY)
- `.claude/orchestration.md` — 원칙 보존 검증 필요
- `.claude/skills/*/SKILL.md` — 절차 무결성 검증 필요
- `.claude/context/conventions.md` — 기존 규칙과 충돌 검증 필요

## Tamper-proof Declaration

- This file is NOT a target of /srpi-implement or any SRPI phase
- Agents may ONLY read this file, never modify it
- Only the human creator may alter this document through direct edit
