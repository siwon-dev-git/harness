# SRPI Conventions

## 공통 규칙

- 즉시 기록: 발견 즉시 wip 파일에 기록. 배치 금지.
- 커밋 금지: 사용자가 직접 확인 후 커밋.
- 검증 필수: 각 스킬 완료 후 validate.sh 실행.
- 컨텍스트 관리: 대화가 길어지면 사용자에게 /compact 요청.

## C#-E# 매핑 형식

```
C1: [주장] ← E1: [CODE] file:line · 인용 [FACT]
```

- 태그: [FACT] · [INFERENCE] · [HYPOTHESIS]
- HYPOTHESIS는 최종 결론 불가 (승격 필요)
- 근거 수준: L1(코드/공식문서) 필수, L3(커뮤니티) 단독 불가

## 점수 기준

| 점수 | 의미 |
|------|------|
| 9-10 | 모범 사례. 개선 여지 거의 없음 |
| 7-8 | 양호. 사소한 개선점 |
| 5-6 | 보통. 명확한 문제 있으나 동작 지장 없음 |
| 3-4 | 미흡. 구조적 문제 또는 리스크 |
| 1-2 | 심각. 즉시 개선 필요 |

## 보호 파일

수정 전 반드시 확인:
- `.claude/constitution.md` — 수정 불가 (READ-ONLY)
- `.claude/orchestration.md` — 원칙 보존 검증 필요
- `.claude/skills/*/SKILL.md` — 절차 무결성 검증 필요
- `.claude/heritage/adr.md` — 항목 삭제 금지, 추가만 허용
- `.claude/heritage/fmea.md` — 항목 삭제 금지, 추가만 허용 (졸업 시 archive로 이동)
- `.claude/heritage/scoreboard.md` — 항목 삭제 금지, 추가만 허용

## 에러 복구 프로토콜

구현 중 검증 실패 시:
1. **멈춤** — 실패 위에 추가 작업 금지
2. **식별** — heritage/fmea.md에서 매칭되는 실패 패턴 확인
3. **롤백** — `git checkout -- <file>`로 원복
4. **수정** — 원인 파악 후 재시도
5. **기록** — 새 실패 패턴이면 fmea.md에 등록

## 난이도 거버넌스

- 태스크 3개 이상: 최소 1개는 M 또는 H
- 난이도 점수 = (L×1 + M×2 + H×3) / 태스크수
- < 1.3 이면 FLAG → verify에서 경고
- FLAG 연속 2회 → 다음 루프에서 M/H 의무

## 스코프 제한

- 단계당 100k 토큰 이내 권장
- 단계 간 `/compact` 실행으로 컨텍스트 정리
- 한 태스크에서 3개 이상 파일 변경 시 — 태스크 분할 고려
