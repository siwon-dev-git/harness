# Failure Patterns

> SRPI 루프에서 축적된 실패 패턴. Detect/Fix/Prevent 구조.
> 태그: `governance`, `validation`, `loop`, `scoring`, `context`

## Scoring

- **self-scoring-inflation** [scoring]
  - Detect: 평가 점수가 실제 코드 상태보다 높음 (특히 7+ 점수의 근거 빈약)
  - Fix: file:line 근거 개수와 점수 상관관계 재검토. 근거 부족 시 하향 조정
  - Prevent: evaluate SKILL.md에 Babel paradox 경고. 7+ 점수는 근거 5개 이상 필요

## Validation

- **validation-inconsistency** [validation]
  - Detect: Loop 9에서 verify/validate.sh만 check_file 후 early exit 미사용. 다른 4개 validator는 `|| { result; exit; }` 패턴 사용
  - Root Cause: validator 작성 시점이 다름. 초기 validator는 early exit 패턴 미확립
  - Fix: Loop 9에서 verify/validate.sh에 early exit 패턴 적용. 5기준 검증도 SRPI_CRITERIA 기반으로 통일
  - Prevent: 새 validator 작성 시 기존 패턴 템플릿 참조. check_file 후 반드시 `|| { result; exit; }` 사용

## Loop Strategy

- **no-impact-criterion** [scoring, loop]
  - Detect: 특정 기준 delta=0 — 해당 영역 관련 태스크 0건 또는 도구 생성만으로 실배치 누락
  - Root Cause: plan 단계에서 특정 기준이 우선순위 경쟁에서 밀리거나, "정책 결정" 성격 이슈를 코드 수정 태스크로 변환하기 어려움
  - Fix: 다음 루프에서 delta=0 영역 태스크 의무 배치
  - Prevent: plan 단계에서 5기준 커버리지 확인. delta=0 영역 태스크 의무 배정. 2루프 연속 delta=0 시 최우선 배정
  - History: Loop 1 보안, Loop 1-2 성능, Loop 2 아키텍처, Loop 3 테스트. Merged from: no-impact-security, no-impact-performance, no-impact-architecture, no-impact-test

- **incomplete-propagation** [loop, validation]
  - Detect: 코드/도구/문서 중 하나만 변경하고 연관 산출물 업데이트 누락
  - Root Cause: "코드 수정 = 문서/배치도 수정" 인식 부재. 변경 태스크와 전파 태스크를 분리하지 않음
  - Fix: 연관 산출물 동시 업데이트. plan에서 "코드+문서" 또는 "도구 생성+배치" 쌍 태스크화
  - Prevent: plan 단계에서 변경 태스크마다 영향 범위(코드/문서/테스트/배치) 체크리스트 검증
  - History: Loop 3 tool-without-deployment, Loop 4 doc-code-mismatch

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
  - See also: incomplete-propagation (도구 배치 누락의 테스트 차원 변형)

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

- **score-plateau-at-ceiling** [scoring, loop]
  - Detect: 전 기준 9/10에서 7/7 태스크 성공에도 delta=0. 결함 수정이 점수 레벨 내 통합에 그침
  - Fix: 10/10 달성을 위해 기준당 잔여 미검증 영역 전수 해결 필요 (통합 테스트, heritage 형식 검증, 테스트 스위트 최적화)
  - Prevent: 9/10 진입 후 plan 단계에서 "10/10 전환 조건"을 태스크 목표로 명시. 결함 수정보다 미검증 영역 발굴 우선

- **unvalidated-task-dependency** [validation, loop]
  - Detect: 선행 필드에 존재하지 않는 T# 또는 순환 참조 → implement 단계 조용한 실패
  - Fix: check_dependency_dag()로 plan validate 시 기계적 검증
  - Prevent: plan validate.sh에 DAG 검증 배치. 통과하지 않으면 implement 진입 불가

- **monolithic-h-task** [loop, governance]
  - Detect: H 태스크를 한 덩어리로 implement → 에러율 급증, 3회 재시도 초과
  - Fix: H 태스크를 M/L 서브태스크로 분해 (T#.N notation)
  - Prevent: check_h_expansion() 검증 + plan SKILL.md에 분해 의무 규칙

## Context

- **context-exhaustion** [context, loop]
  - Detect: 4단계 순차 실행 중 컨텍스트 한도 도달
  - Fix: /compact 실행 또는 단계별 세션 분리
  - Prevent: 단계 간 /compact 권장. 단계당 100k 토큰 이내 권장
