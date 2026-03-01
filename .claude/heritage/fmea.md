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

## Loop Strategy

- **no-impact-security** [scoring, loop]
  - Detect: 보안 기준 delta=0 — 관련 태스크 0건으로 점수 정체
  - Fix: 다음 루프에서 보안 태스크 우선 배치 (href sanitization, script injection, dependabot)
  - Prevent: evaluate 후 plan 단계에서 5기준 커버리지 확인. delta=0 영역 태스크 의무 배정

- **easy-pick-bias** [loop, governance]
  - Detect: 난이도 점수 1.1 (FLAG). L:9 M:1 H:0 — 쉬운 태스크만 선택
  - Fix: 다음 루프에서 M/H 쿼터 확보 (최소 1개 M 또는 H 의무)
  - Prevent: plan 단계에서 난이도 분포 사전 검증. < 1.3 시 태스크 교체

- **no-impact-performance** [scoring, loop]
  - Detect: 성능 기준 delta=0 — 2루프 연속 정체 (Loop 1, Loop 2)
  - Root Cause: plan 단계에서 보안/코드품질 우선 배치로 성능 태스크 경쟁에서 밀림. 성능 이슈가 "동작에 지장 없음"으로 분류되어 우선순위 하락
  - Fix: 다음 루프에서 성능 태스크 의무 배치 (key={i}, inline style 객체, lib 빌드 최적화)
  - Prevent: plan 단계에서 5기준 커버리지 확인. 2루프 연속 delta=0 영역 최우선 배정

- **no-impact-architecture** [scoring, loop]
  - Detect: 아키텍처 기준 delta=0 — Loop 2에서 관련 태스크 0건
  - Root Cause: 아키텍처 이슈(@theme inline, peerDependencies)가 "정책 결정" 성격이라 코드 수정 태스크로 변환하기 어려움
  - Fix: 다음 루프에서 아키텍처 태스크 배치 (@theme inline L1 참조, peerDependencies 정책)
  - Prevent: plan 단계에서 delta=0 영역 태스크 의무 배정

- **no-impact-test** [scoring, loop]
  - Detect: 테스트 기준 delta=0 — Loop 3에서 check_no_pattern/check_section_order 추가했으나 validate.sh에서 호출 0건
  - Root Cause: 구현 단계에서 "함수 추가"와 "함수 배치"를 별도 태스크로 분리하지 않아, 도구만 만들고 적용은 누락
  - Fix: 다음 루프에서 lib.sh 함수를 validate.sh에 실제 배치. check_section_order로 wip 섹션 순서 검증, check_no_pattern으로 금지 패턴 체크
  - Prevent: plan 단계에서 "함수 추가" 태스크와 "함수 배치" 태스크를 명시적으로 분리. 도구 생성 ≠ 활용

- **tool-without-deployment** [loop, validation]
  - Detect: Loop 3에서 lib.sh 함수 추가했으나 validate.sh 배치 누락 → 테스트 delta=0
  - Root Cause: "함수 추가" 태스크만 만들고 "함수 배치" 태스크를 별도로 만들지 않음
  - Fix: Loop 4에서 check_section_order를 evaluate/validate.sh에, check_no_pattern을 verify/validate.sh에 실배치
  - Prevent: plan 단계에서 도구 생성과 도구 배치를 별도 태스크로 분리. "만들기 ≠ 쓰기"

- **doc-code-mismatch** [loop, validation]
  - Detect: Loop 4에서 코드(validate.sh)를 grep -oE로 수정했으나 문서(SKILL.md)에 grep -oP 잔존. 에이전트가 문서 패턴 복사 시 실패
  - Root Cause: 코드 수정 태스크와 문서 수정 태스크를 분리하지 않음. "코드 고침 = 문서도 고침"이 아니었음
  - Fix: Loop 6에서 verify/SKILL.md 자동화 경로를 grep -oE로 수정 + parse-scores.sh 참조 추가
  - Prevent: 코드 수정 시 관련 SKILL.md 자동화 경로/예제도 동시 업데이트. plan 단계에서 "코드+문서" 쌍 태스크화

- **validator-gap** [validation, loop]
  - Detect: Loop 7에서 test-validators.sh가 evaluate/research/plan만 테스트. 70줄 verify validator 미검증
  - Root Cause: "복잡한 validator = 중요한 validator"이지만 테스트 작성 비용도 높아 후순위로 밀림
  - Fix: Loop 8에서 implement/verify validator negative 테스트 6개 추가 (16→16 PASS)
  - Prevent: 새 validator 생성 시 test-validators.sh에 3개 시나리오(missing/valid/invalid) 동반 추가 의무

- **untested-utility** [loop, validation]
  - Detect: Loop 6에서 parse-scores.sh, loop-status.sh 생성했으나 테스트 0건. Loop 7 evaluate에서 테스트 기준 정체 원인으로 식별
  - Root Cause: "유틸리티 스크립트 = 단순 도구"로 간주해 테스트 불필요하다고 판단. 그러나 bc/awk 파싱 로직은 엣지케이스 취약
  - Fix: Loop 7에서 test-lib.sh에 parse-scores.sh(2), loop-status.sh(3) 테스트 추가 + test-validators.sh(9) 신설
  - Prevent: plan 단계에서 새 스크립트 생성 태스크마다 "테스트 추가" 동반 태스크 의무 배정. "만들기 = 테스트하기"

- **validation-inconsistency** [validation]
  - Detect: Loop 9에서 verify/validate.sh만 check_file 후 early exit 미사용. 다른 4개 validator는 `|| { result; exit; }` 패턴 사용
  - Root Cause: validator 작성 시점이 다름. 초기 validator는 early exit 패턴 미확립
  - Fix: Loop 9에서 verify/validate.sh에 early exit 패턴 적용. 5기준 검증도 SRPI_CRITERIA 기반으로 통일
  - Prevent: 새 validator 작성 시 기존 패턴 템플릿 참조. check_file 후 반드시 `|| { result; exit; }` 사용

## Performance

- **multi-scan-inefficiency** [performance, loop]
  - Detect: 스크립트가 동일 파일을 N×M회 반복 스캔 (parse-scores.sh 5기준×2grep=10회, check_range 이중 grep)
  - Root Cause: 기준별 for 루프 내 grep 호출은 직관적이지만, 기준 수 증가 시 선형 비용 증가. "동작함"이 "최적"으로 오인됨
  - Fix: awk 단일 패스로 전체 파일 1회 스캔. 메모리 내 결과를 기준별로 검색 (parse-scores.sh). bash 파라미터 확장으로 grep 파이프 제거 (check_range)
  - Prevent: 새 파일 파싱 스크립트 작성 시 "파일 스캔 횟수"를 성능 지표로 점검. for+grep → awk 단일 패스 우선 고려

- **hardcoded-schema-index** [performance, validation]
  - Detect: awk $9처럼 컬럼 인덱스 하드코딩. 스키마 변경 시 무조건 파괴
  - Root Cause: 초기 구현에서 scoreboard 스키마가 고정이라 가정. append-only 정책이 "컬럼 변경 없음"을 보장하지 않음
  - Fix: 헤더 행에서 컬럼명("평균")으로 인덱스 동적 추출
  - Prevent: 테이블 데이터 파싱 시 항상 헤더 기반 인덱싱 사용. 숫자 리터럴 컬럼 참조 금지

## Context

- **context-exhaustion** [context, loop]
  - Detect: 4단계 순차 실행 중 컨텍스트 한도 도달
  - Fix: /compact 실행 또는 단계별 세션 분리
  - Prevent: 단계 간 /compact 권장. 단계당 100k 토큰 이내 권장
