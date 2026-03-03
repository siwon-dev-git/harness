# Decisions Registry

> SRPI 루프에서 축적된 설계 결정. 이름 [태그]: 결정 + Background.
> 태그: `governance`, `validation`, `loop`, `heritage`, `context`, `performance`

## Governance (3)

- **constitution-trust-anchor** [governance]: 불변 원칙 파일(constitution.md) 도입. 에이전트 수정 불가, 사용자만 변경
  - Background: 자기 규칙 자기 수정 → 신뢰 기반 붕괴. 불변 앵커 필요
- **protected-file-list** [governance]: 보호 파일 목록 명시. 수정 시 mutation safety 3단계 검증 필수
  - Background: constitution만 보호하면 heritage 파일이 무방비. 계층별 보호 수준 필요
- **babel-paradox-defense** [governance]: Self-scoring 편향을 Hard Constraint로 등록. 평가 시 경고 의무
  - Background: Loop 1에서 점수 부풀림 관찰. 정량적 근거 요구로 방어

## Validation (6)

- **sequential-gate-enforcement** [validation, loop]: 이전 단계 validate PASS 없이 다음 단계 진입 불가
  - Background: 불완전한 산출물 위에 다음 단계 쌓으면 오류 전파
- **validate-retry-limit** [validation]: 단계당 최대 3회 재시도. 초과 시 BLOCKED
  - Background: 무한 재시도 → 컨텍스트 소진. 3회 제한으로 실패 빠르게 인정
- **evidence-based-scoring** [validation]: 모든 점수 판정에 file:line 근거 필수. 근거 없는 점수 무효
  - Background: 정성 판단은 재현 불가. 코드 위치 기반 근거만 허용
- **dag-dependency-validation** [validation, governance]: plan T# 의존성을 Kahn's DAG로 검증. 순환/미참조/루트 부재 탐지
  - Background: T# 선행 필드가 텍스트 전용이면 순환 의존 무방비. bash 3.2 호환(문자열+grep 기반)
- **next-task-algorithm** [loop, governance]: implement 단계 의존성 기반 실행 순서. Ready 집합 + H>M>L 우선순위
  - Background: Ready 집합 기계적 계산으로 순서 실수 구조적 차단
- **complexity-driven-expansion** [governance]: H 난이도 태스크 서브태스크 분해 의무화. T#.N dot notation
  - Background: H 태스크 한 덩어리 implement → 에러율 급증. M/L 서브태스크로 분해하여 단위 검증

## Loop (3)

- **wip-file-state-detection** [loop]: wip 파일 존재 여부로 재개 지점 판단. missing부터 실행
  - Background: 파일 존재 = 재개 지점 판단의 가장 단순한 신호
- **cleanup-after-completion** [loop]: 5단계 모두 완료 후 cleanup.sh로 wip/bak 파일 제거
  - Background: FMEA wip-residual-confusion 교훈
- **no-commit-policy** [loop]: implement 단계에서 커밋 금지. 사용자 직접 확인 후 커밋

## Heritage (3)

- **heritage-accumulation** [heritage]: ADR(결정) + FMEA(실패 패턴)로 경험 축적. 루프마다 갱신
  - Background: heritage로 루프 간 기억 영속화. 학습 없이는 같은 실수 반복
- **detect-fix-prevent** [heritage]: FMEA 항목은 탐지→수정→예방 3단계 구조
- **heritage-compaction** [heritage, governance]: 중복 FMEA 통합(6→2) + 졸업 메커니즘(3건) + scoreboard 데이터 정합성. 지식 무손실 원칙
  - Background: 12루프 축적 후 정리. conventions.md "졸업 시 archive로 이동" 규정 최초 적용

## Verification (4)

- **vf-layer** [loop, heritage]: VF 단계 도입. 점수 delta + heritage 자동 업데이트로 피드백 루프 폐합
  - Background: implement 후 "개선됐다고 가정" → Babel Paradox. 재평가로 실제 delta 측정
- **scoreboard-tracking** [heritage]: scoreboard.md로 루프별 점수 영속 추적. append-only
  - Background: 점수 추이 없이는 정체/하락 감지 불가
- **archive-before-cleanup** [loop]: cleanup 전 logs/archive/loop-NNN/에 wip 파일 보존
  - Background: cleanup이 wip를 삭제하므로 archive로 감사 추적 가능
- **difficulty-governance** [loop, governance]: 난이도 점수 + 최소 쿼터로 easy-pick 편향 방어
  - Background: Loop 1 FLAG(L:9 M:1 H:0). 난이도 하한 + check_difficulty_sum으로 기계적 강제

## Performance (6)

> Loop 10 성능 최적화 계열 포함: 파일 스캔/파싱 O(N×M)→O(1) 전환

- **automation-scripts** [performance]: 자동화 유틸리티(parse-scores.sh, loop-status.sh)를 독립 스크립트로 분리
  - Background: SKILL.md 내 인라인 bash는 재사용 불가 + macOS 비호환
- **timing-in-validation** [performance]: result() 함수에 실행 시간(초) 출력 추가
  - Background: 어떤 validator가 느린지 정량 추적
- **cleanup-precondition** [performance, validation]: cleanup.sh에 5개 wip 사전 검증 추가. 불완전 상태 방어
  - Background: WARNING만으로는 삭제 진행됨. 사전 ABORT가 더 안전
- **single-pass-optimization** [performance]: 다중 grep → awk 단일 패스 전환. 파일 스캔 O(N×M) → O(1)
  - Background: parse-scores.sh 10회 스캔 → 1회. check_range grep → bash 파라미터 확장
- **dynamic-column-index** [performance, validation]: scoreboard 컬럼 하드코딩 → 헤더 기반 동적 추출
  - Background: 스키마 변경 시 파괴 방지. 1회 비용으로 장기 유지보수 안전성 확보
- **unified-test-runner** [performance]: run-tests.sh로 test-lib.sh + test-validators.sh 통합 실행
  - Background: 2개 스크립트 → 1번 실행. 개별 스크립트 유지하여 디버깅 편의 보존

## Testing (6)

- **meta-testing** [validation, loop]: validator 자체를 테스트하는 test-validators.sh 도입. 의도적 불량 입력으로 FAIL 확인
  - Background: negative test로 validator 신뢰도 확보. 3 validator × 3 시나리오 = 9개 테스트
- **test-accompaniment** [validation]: 새 스크립트/함수 생성 시 동반 테스트 의무화. "만들기 = 테스트하기"
  - Background: Loop 6에서 테스트 없이 생성 → FMEA untested-utility. 도구와 테스트 분리 → 누락 100%
- **criteria-dedup** [performance, validation]: 5기준 배열을 lib.sh SRPI_CRITERIA로 공유 정의. SSOT 확보
  - Background: 기준명 3중 정의(validate.sh, parse-scores.sh, conventions.md) → 동기화 실패 위험
- **difficulty-invariant** [validation, governance]: plan/validate.sh에 L+M+H 합 == T# 수 불변식 검증
  - Background: check_difficulty_sum으로 난이도-태스크 수 불일치 감지
- **archive-integrity-abort** [validation, heritage]: cleanup.sh 아카이브 불완전 시 ABORT. WARNING→hard fail
  - Background: "경고만" 정책은 무결성 보장 불가. 데이터 소실 위험
- **verify-early-exit** [validation]: verify/validate.sh에 check_file early exit 패턴 통일
  - Background: verify만 early exit 누락 → 파일 부재 시 에러 폭주. 패턴 일관성 확보
