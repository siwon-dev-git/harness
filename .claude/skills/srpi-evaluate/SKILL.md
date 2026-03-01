---
name: srpi-evaluate
description: 코드베이스를 5개 기준으로 평가하여 logs/quest-wip.md를 생성한다.
disable-model-invocation: true
---

코드베이스를 [평가 기준](../../context/conventions.md)으로 평가하여 [template.md](template.md) 형식으로 `logs/quest-wip.md`에 기록한다.

## 절차

1. **Heritage 확인**: `.claude/heritage/fmea.md`에서 이전 실패 패턴 확인. 해당 기준 평가 시 반영
2. **기준별 탐색**: 5개 기준(코드 품질, 아키텍처, 테스트, 보안, 성능) 순차 탐색
3. **근거 수집**: 각 기준마다 file:line 근거 최소 3개 확보
4. **점수 판정**: 근거 기반으로 점수 부여. 즉시 wip 파일에 기록
5. **요약 작성**: 5개 기준 점수 테이블 + 평균

## Self-scoring 편향 방어 (Babel Paradox)

⚠️ 자기 코드를 자기가 평가하면 점수가 부풀어오른다. 다음 규칙으로 방어:

- 7점 이상 부여 시: file:line 근거 5개 이상 필수. 근거 부족하면 6점으로 하향
- "양호", "잘 되어 있음" 같은 정성적 판단 금지 — 구체적 증거만 허용
- 이전 루프 평가와 비교: 개선 근거 없이 점수가 올랐으면 재검토
- 의심스러우면 낮은 점수 쪽으로 — 과소평가가 과대평가보다 안전

## 검증

완료 후 `bash .claude/skills/srpi-evaluate/validate.sh` 실행.
