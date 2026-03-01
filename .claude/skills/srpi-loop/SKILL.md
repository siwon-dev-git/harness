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

## 에러 처리

- **validate 실패 시**: 해당 단계 내에서 수정 후 재검증. 최대 3회 재시도
- **3회 초과 시**: BLOCKED 기록 후 중단. FMEA에 실패 패턴 등록
- **단계 건너뛰기 금지**: 이전 단계 PASS 없이 다음 단계 진입 불가 (순차 강제)
- **컨텍스트 소진 시**: 현재 단계의 wip 파일이 체크포인트 역할. 재시작 시 상태 감지로 재개

## 규칙

- [공통 규칙](../../context/conventions.md) 준수
- [orchestration.md](../../orchestration.md) Rules 섹션 참조
- heritage 파일 수정 시: [Risk 분류](../../orchestration.md) 확인
