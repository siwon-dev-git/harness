---
name: srpi-research
description: 평가 결과를 근거 기반으로 분석하여 logs/research-wip.md를 생성한다.
---

`logs/quest-wip.md`에서 7점 미만 영역을 추출하고, [방법론](../../context/methodology.md)에 따라 근거 수집 + 반증 루프를 실행하여 [template.md](template.md) 형식으로 `logs/research-wip.md`에 기록한다.

## 전제 조건

- `logs/quest-wip.md` 존재 필수. 없으면 중단하고 `/srpi-evaluate` 안내
- `bash .claude/skills/srpi-evaluate/validate.sh` PASS 확인

## 절차

1. **영역 추출**: quest-wip.md에서 7점 미만 기준 식별. 7점 이상도 개선 여지 있으면 포함
2. **FMEA 확인**: `.claude/heritage/fmea.md`에서 관련 실패 패턴 확인. 반복 방지
3. **근거 수집**: 영역별 코드 탐색. C#-E# 형식으로 주장+근거 매핑
   - 태그: [FACT] · [INFERENCE] · [HYPOTHESIS]
   - 근거 수준: L1(코드/공식문서) 필수, L3(커뮤니티) 단독 불가
4. **반증 루프**: 영역당 최소 2회 Counter-hypothesis 작성 → 반증 시도
   - 반증 성공: 주장 archive (근거 + 이유 기록)
   - 반증 실패 2회+: 검증 완료
5. **해결 방안**: 영역별 2-3개 방안 제시. 임팩트/난이도 명시
6. **추천**: 방안 선택 이유를 C#-E# 기반으로 작성
7. **요약 테이블**: 영역별 점수, 핵심 문제, 추천 방안, 임팩트

## 규칙

- [공통 규칙](../../context/conventions.md) 준수
- 발견 즉시 wip에 기록 (배치 금지)
- HYPOTHESIS 태그는 최종 결론 불가 (FACT/INFERENCE 승격 필요)

## 검증

완료 후 `bash .claude/skills/srpi-research/validate.sh` 실행.
