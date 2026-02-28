# Failure Patterns

> SRPI 루프에서 축적된 실패 패턴. Detect/Fix/Prevent 구조.
> 태그: `governance`, `validation`, `loop`, `scoring`, `context`

## Scoring

- **self-scoring-inflation** [scoring]
  - Detect: 평가 점수가 실제 코드 상태보다 높음 (특히 7+ 점수의 근거 빈약)
  - Fix: file:line 근거 개수와 점수 상관관계 재검토. 근거 부족 시 하향 조정
  - Prevent: evaluate SKILL.md에 Babel paradox 경고. 7+ 점수는 근거 5개 이상 필요

## Validation

- **validate-silent-pass** [validation]
  - Detect: grep -c 반환값 0일 때 set -e로 스크립트 전체 중단
  - Fix: `|| true`로 grep 실패를 안전하게 처리 (lib.sh check_count)
  - Prevent: 새 check 함수 추가 시 grep 종료 코드 처리 패턴 준수

- **wip-residual-confusion** [loop, validation]
  - Detect: 이전 루프의 wip 파일이 남아서 재개 지점 오판
  - Fix: cleanup.sh 실행으로 잔여 파일 제거
  - Prevent: 루프 시작 시 이전 wip 파일 상태 확인 + 사용자에게 안내

## Context

- **context-exhaustion** [context, loop]
  - Detect: 4단계 순차 실행 중 컨텍스트 한도 도달
  - Fix: /compact 실행 또는 단계별 세션 분리
  - Prevent: 단계 간 /compact 권장. 단계당 100k 토큰 이내 권장
