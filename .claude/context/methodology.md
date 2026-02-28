# Falsification Methodology

## Falsification Loop (영역당 min 2 / max 5)

1. 현재 주장의 약점/공백 식별
2. 추가 검증 또는 새 근거 수집
3. 자기 주장 반증 시도
4. wip 파일에 즉시 기록
5. 신뢰도 재평가 → 다음 루프 계획

종료: min 충족 + 마지막 루프 material update 0건
FAIL: 루프에서 material update 0건이면 해당 루프 무효

## Source Hierarchy

| 레벨 | 소스 유형 | 예시 |
|------|----------|------|
| L1 | 코드 직접 확인, 공식 문서/스펙 | 소스 코드, RFC |
| L2 | 공식 기술 블로그, 학술 자료 | React 블로그, ACM 논문 |
| L3 | 커뮤니티, 개인 블로그 | Reddit, Medium, SO |

핵심 결론은 L1 필수. L3 단독은 최종 결론 불가.

## 근거 형식

```
E1: [CODE] file:line · 인용 [FACT]
E2: [DOC] url · 인용 [FACT]
E3: [WEB] url · 인용 [INFERENCE]
```

## 반증 판정

- 반증 성공: 코드에서 반대 근거 발견 (L1 수준) → archive (근거 + 이유 기록)
- 반증 실패: 2회 이상 시도 후 반대 근거 없음 → 검증 완료
- 판정 불가: 근거 수준이 L3뿐이거나 코드 접근 불가 → 불확실성 태그, 추가 루프
