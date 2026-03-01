---
name: srpi-verify
description: 구현 결과를 재평가하고 점수 delta를 측정한다. Heritage 자동 업데이트.
---

## 입력

- `logs/quest-wip.md` — Pre-score (5기준 점수)
- `logs/impl-wip.md` — 구현 결과 (태스크 상태)
- `logs/plan-wip.md` — 태스크 난이도 정보

## 출력

- `logs/verify-wip.md` — template.md 형식

## 절차

### 1. 루프 번호 결정

`.claude/heritage/scoreboard.md` 데이터 행 수 + 1.

### 2. Pre-score 파싱

`quest-wip.md` 요약에서 5개 점수 추출:
- 코드 품질, 아키텍처, 테스트, 보안, 성능 (각 N/10)

### 3. 영향 영역 판별

`impl-wip.md` + `plan-wip.md`에서 변경된 파일과 영향받은 기준 식별.
- 태스크별 관련 기준 매핑
- 변경된 file:line 목록 수집

### 4. 재평가 (Babel Paradox 방어)

영향받은 기준만 코드 재확인. 미영향 기준은 원래 점수 유지.

**Babel Paradox 방어 규칙:**
- 점수 상승 시: before/after file:line 근거 쌍 필수
- +1 이상 상승: 근거 5개 이상 필수
- 의심 시 delta=0 — **과소평가 > 과대평가**

### 5. 델타 계산

Post - Pre. 미변경 기준은 delta=0.

### 6. 난이도 감사

`plan-wip.md`에서 L/M/H 집계:
- 난이도 점수 = (L×1 + M×2 + H×3) / 태스크수
- < 1.3 이면 FLAG

### 7. Heritage 자동 업데이트

#### scoreboard.md
루프 결과 행 1개 추가 (append-only).

#### fmea.md
- 실패 태스크(❌) → Detect/Fix/Prevent 자동 등록
- 점수 미개선 영역 → "no-impact" 패턴 등록

### 8. 다음 루프 권고

- 정체/하락 영역 식별
- 난이도 상향 필요 여부
- 우선 공략 대상 제안

## 검증

```bash
bash .claude/skills/srpi-verify/validate.sh
```
