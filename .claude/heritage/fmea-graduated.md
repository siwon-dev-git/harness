# Graduated Failure Patterns

> FMEA에서 구조적으로 해결된 패턴. conventions.md "졸업 시 archive로 이동" 정책에 의거.
> 재발 시 fmea.md로 재등록.

## Validation

- **validate-silent-pass** [validation] — Graduated Loop 13
  - Detect: grep -c 반환값 0일 때 set -e로 스크립트 전체 중단
  - Fix: `|| true`로 grep 실패를 안전하게 처리 (lib.sh check_count)
  - Prevent: 새 check 함수 추가 시 grep 종료 코드 처리 패턴 준수
  - Graduation: lib.sh 전 함수에 `|| true` 패턴 적용 완료. verify-early-exit + validation-inconsistency ADR로 구조적 방어

- **wip-residual-confusion** [loop, validation] — Graduated Loop 13
  - Detect: 이전 루프의 wip 파일이 남아서 재개 지점 오판
  - Fix: cleanup.sh 실행으로 잔여 파일 제거
  - Prevent: 루프 시작 시 이전 wip 파일 상태 확인 + 사용자에게 안내
  - Graduation: cleanup.sh ABORT 정책(archive-integrity-abort ADR) + 5개 wip 사전 검증으로 구조적 방어

## Loop Strategy

- **easy-pick-bias** [loop, governance] — Graduated Loop 13
  - Detect: 난이도 점수 1.1 (FLAG). L:9 M:1 H:0 — 쉬운 태스크만 선택
  - Fix: 다음 루프에서 M/H 쿼터 확보 (최소 1개 M 또는 H 의무)
  - Prevent: plan 단계에서 난이도 분포 사전 검증. < 1.3 시 태스크 교체
  - Graduation: difficulty-governance ADR + check_difficulty_sum validator로 기계적 강제. plan/validate.sh에서 < 1.3 자동 FAIL
