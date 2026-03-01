# Decisions Registry

> SRPI 루프에서 축적된 설계 결정. 이름 [태그]: 결정 + Background.
> 태그: `governance`, `validation`, `loop`, `heritage`, `context`, `performance`

## Governance

- **constitution-trust-anchor** [governance]: 불변 원칙 파일(constitution.md) 도입. 에이전트 수정 불가, 사용자만 변경
  - Background: 에이전트가 자기 규칙을 자기가 수정하면 자기개선 루프의 신뢰 기반이 무너짐. 불변 앵커 필요
- **protected-file-list** [governance]: 보호 파일 목록 명시. 수정 시 mutation safety 3단계 검증 필수
  - Background: constitution만 보호하면 heritage 파일이 무방비. 계층별 보호 수준 필요
- **babel-paradox-defense** [governance]: Self-scoring 편향을 Hard Constraint로 등록. 평가 시 경고 의무
  - Background: Loop 1에서 자기 코드 자기 평가 시 점수 부풀림 관찰. 정량적 근거 요구로 방어

## Validation

- **sequential-gate-enforcement** [validation, loop]: 이전 단계 validate PASS 없이 다음 단계 진입 불가
  - Background: 불완전한 중간 산출물 위에 다음 단계를 쌓으면 오류 전파. validate 게이트로 차단
- **validate-retry-limit** [validation]: 단계당 최대 3회 재시도. 초과 시 BLOCKED
  - Background: 무한 재시도는 컨텍스트 소진. 3회 제한으로 실패를 빠르게 인정하고 FMEA에 기록
- **evidence-based-scoring** [validation]: 모든 점수 판정에 file:line 근거 필수. 근거 없는 점수 무효
  - Background: "양호함" 같은 정성 판단은 재현 불가. 코드 위치 기반 근거만 허용

## Loop

- **wip-file-state-detection** [loop]: wip 파일 존재 여부로 재개 지점 판단. missing부터 실행
  - Background: 컨텍스트 소진 후 재시작 시 어디부터 이어할지 판단 근거 필요. 파일 존재가 가장 단순
- **cleanup-after-completion** [loop]: 5단계 모두 완료 후 cleanup.sh로 wip/bak 파일 제거
  - Background: 이전 루프 wip 잔존 시 다음 루프 재개 지점 오판 (FMEA wip-residual-confusion)
- **no-commit-policy** [loop]: implement 단계에서 커밋 금지. 사용자 직접 확인 후 커밋
  - Background: 자동 커밋은 되돌리기 어려운 부작용. 사용자 승인 게이트 유지

## Heritage

- **heritage-accumulation** [heritage]: ADR(결정) + FMEA(실패 패턴)로 경험 축적. 루프마다 갱신
  - Background: 루프 간 학습 없이 같은 실수 반복. heritage로 루프 간 기억 영속화
- **detect-fix-prevent** [heritage]: FMEA 항목은 탐지→수정→예방 3단계 구조
  - Background: 단순 "실패 기록"은 재발 방지 불가. 3단계로 구조화해야 actionable

## Verification

- **vf-layer** [loop, heritage]: VF 단계 도입. 점수 delta + heritage 자동 업데이트로 피드백 루프 폐합
  - Background: implement 후 "개선됐다고 가정"하면 Babel Paradox. 재평가로 실제 delta 측정
- **scoreboard-tracking** [heritage]: scoreboard.md로 루프별 점수 영속 추적. append-only
  - Background: 점수 추이 없이는 정체/하락 감지 불가. 시계열 데이터 필수
- **archive-before-cleanup** [loop]: cleanup 전 logs/archive/loop-NNN/에 wip 파일 보존. 기억 소실 방지
  - Background: cleanup이 wip를 삭제하므로 중간 산출물 소실. archive로 감사 추적 가능
- **difficulty-governance** [loop, governance]: 난이도 점수 + 최소 쿼터로 easy-pick 편향 방어
  - Background: Loop 1에서 L:9 M:1 H:0 (FLAG). 쉬운 태스크만 골라 점수 부풀림. 난이도 하한 필요

## Performance

- **automation-scripts** [performance]: 자동화 유틸리티(parse-scores.sh, loop-status.sh)를 독립 스크립트로 분리
  - Background: SKILL.md 내 인라인 bash나 문서 수준 자동화 경로는 재사용 불가 + macOS 비호환. 독립 스크립트로 분리해야 일관된 실행 보장
- **timing-in-validation** [performance]: result() 함수에 실행 시간(초) 출력 추가
  - Background: 검증 체크 증가에 따른 성능 모니터링 근거 필요. 어떤 validator가 느린지 정량 추적
- **cleanup-precondition** [performance, validation]: cleanup.sh에 5개 wip 사전 검증 추가. 불완전 상태 방어
  - Background: Loop 5에서 아카이브 무결성 WARNING 추가했으나 삭제는 진행됨. 사전 중단이 더 안전

## Testing

- **meta-testing** [validation, loop]: validator 자체를 테스트하는 test-validators.sh 도입. 의도적 불량 입력으로 FAIL 확인
  - Background: validator가 PASS만 내면 "검증이 동작하는지" 확인 불가. negative test로 validator 신뢰도 확보. Loop 7에서 evaluate/research/plan 3개 validator × 3 시나리오 = 9개 테스트
- **test-accompaniment** [validation]: 새 스크립트/함수 생성 시 동반 테스트 의무화. "만들기 = 테스트하기" 원칙
  - Background: Loop 6에서 parse-scores.sh, loop-status.sh를 테스트 없이 생성. Loop 7에서 FMEA untested-utility로 식별. 도구 생성과 테스트를 분리하면 테스트 누락 100%
- **criteria-dedup** [performance, validation]: 5기준 배열을 lib.sh SRPI_CRITERIA로 공유 정의. 중복 제거
  - Background: evaluate/validate.sh(5행 반복), parse-scores.sh(CRITERIA 배열), conventions.md에 기준명 3중 정의. 변경 시 동기화 실패 위험. 공유 정의로 단일 진실 원천(SSOT) 확보
- **difficulty-invariant** [validation, governance]: plan/validate.sh에 L+M+H 합 == T# 태스크 수 불변식 검증 추가
  - Background: 난이도 분포 데이터가 태스크 수와 불일치해도 감지 불가. check_difficulty_sum으로 불변식 강제
