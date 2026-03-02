---
name: srpi-implement
description: 계획 순서대로 구현하고 검증하여 logs/impl-wip.md를 생성한다. 커밋하지 않음.
---

`logs/plan-wip.md`의 태스크(T#)를 실행 순서대로 구현하고, [template.md](template.md) 형식으로 `logs/impl-wip.md`에 기록한다.

## 전제 조건

- `logs/plan-wip.md` 존재 필수. 없으면 중단하고 `/srpi-plan` 안내
- `bash .claude/skills/srpi-plan/validate.sh` PASS 확인

## 절차

1. **plan 파싱**: plan-wip.md에서 T# 태스크 목록 + 선행 의존성 추출
2. **의존성 기반 실행**: 아래 알고리즘으로 다음 태스크 결정 (실행 순서 텍스트는 참고용)
   - **Ready 집합**: 선행 태스크가 모두 ✅인 T# 또는 선행: 없음인 T#
   - **우선순위**: Ready 집합 내에서 H > M > L 난이도 순 (동일 시 T# 번호 순)
   - **선택**: Ready 집합에서 최상위 1개 실행
   - **갱신**: 완료(✅) 후 Ready 집합 재계산 → 반복
   - **교착 감지**: Ready 집합이 비었는데 미완료 태스크 존재 → BLOCKED 기록
   - **불변식**: DAG 검증(check_dependency_dag) PASS → Ready 집합 항상 ≥ 1개
3. **태스크 구현**: Ready에서 선택된 태스크 실행
   - 변경 전 대상 파일 읽기 (현재 상태 확인)
   - 변경 적용
   - 태스크별 검증 수행 (plan에 명시된 검증 방법)
4. **상태 기록**: 각 태스크 완료 즉시 impl-wip.md에 기록
   - ✅ 성공: 변경 파일:라인, 검증 결과
   - ❌ 실패: 원인, 롤백 여부
   - ⏭ 스킵: 선행 태스크 실패로 인한 스킵
5. **요약 작성**: 전체 태스크 상태 테이블 + 성공률

## 에러 복구

- 검증 실패 시: 즉시 멈춤 → 원인 식별 → `git checkout -- <file>`로 롤백 → 수정 → 재시도
- 선행 태스크 ❌ 시: 해당 태스크에 의존하는 모든 태스크 ⏭ 처리 (전이적 스킵)
  - 예: T1 ❌ → T2(선행:T1) ⏭ → T3(선행:T2) ⏭ (연쇄)
- 3회 재시도 초과: BLOCKED 기록, 다음 태스크로 이동

## 규칙

- [공통 규칙](../../context/conventions.md) 준수
- **커밋 금지** — 사용자가 직접 확인 후 커밋
- 보호 파일 수정 시: mutation safety 3단계 검증 (constitution.md 참조)
- 한 태스크에서 3개 이상 파일 변경 시: 태스크 분할 고려

## 검증

완료 후 `bash .claude/skills/srpi-implement/validate.sh` 실행.
