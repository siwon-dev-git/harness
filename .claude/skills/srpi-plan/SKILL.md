---
name: srpi-plan
description: 리서치 결과를 기반으로 우선순위 정렬된 구현 계획을 수립하여 logs/plan-wip.md를 생성한다.
---

`logs/research-wip.md`의 추천 방안을 태스크(T#)로 분해하고, [template.md](template.md) 형식으로 `logs/plan-wip.md`에 기록한다.

## 전제 조건

- `logs/research-wip.md` 존재 필수. 없으면 중단하고 `/srpi-research` 안내
- `bash .claude/skills/srpi-research/validate.sh` PASS 확인

## 절차

1. **방안 매핑**: research-wip.md의 추천 방안을 태스크 단위로 분해
2. **FMEA 확인**: `.claude/heritage/fmea.md`에서 no-impact-criterion, incomplete-propagation 패턴 확인
3. **태스크 작성**: 각 T#에 대상 파일, 변경 내용, 검증 방법, C# 근거 명시
4. **난이도 배정**: L(1점)/M(2점)/H(3점) 배정. FMEA 패턴 반영
5. **난이도 검증**: 점수 = (L×1 + M×2 + H×3) / 태스크수 ≥ 1.3 (미달 시 태스크 교체)
6. **5기준 커버리지 확인**: delta=0 영역(FMEA no-impact-criterion)에 태스크 의무 배정
7. **실행 순서**: 의존성 기반 순서 결정. 독립 태스크는 병렬 가능 표기

## 난이도 기준

| 난이도 | 기준 |
|--------|------|
| L | 단일 파일, 10줄 이내 변경, 패턴 적용 |
| M | 2-3파일, 설계 판단 필요, 새 함수/규칙 |
| H | 3+파일, 아키텍처 결정, 새 시스템/패턴 도입 → **서브태스크 분할 필수** |

## 규칙

- [공통 규칙](../../context/conventions.md) 준수
- 태스크 3개 이상: 최소 1개 M 또는 H 의무
- FLAG 연속 2회 → M/H 의무
- **H 난이도 분할 의무**: H 태스크는 서브태스크(T#.1, T#.2, ...)로 분해 필수
  - 각 서브태스크: M 또는 L만 허용
  - 부모 T#은 헤더 유지, 난이도 배정은 서브태스크에만 적용
  - 난이도 분포: 서브태스크 기준 집계 (H 부모는 카운트 제외)

## 검증

완료 후 `bash .claude/skills/srpi-plan/validate.sh` 실행.
