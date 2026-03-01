# Decisions Registry

> SRPI 루프에서 축적된 설계 결정. 1줄 형식: 이름 [태그] → 결정.
> 태그: `governance`, `validation`, `loop`, `heritage`, `context`, `performance`

## Governance

- **constitution-trust-anchor** [governance]: 불변 원칙 파일(constitution.md) 도입. 에이전트 수정 불가, 사용자만 변경
- **protected-file-list** [governance]: 보호 파일 목록 명시. 수정 시 mutation safety 3단계 검증 필수
- **babel-paradox-defense** [governance]: Self-scoring 편향을 Hard Constraint로 등록. 평가 시 경고 의무

## Validation

- **sequential-gate-enforcement** [validation, loop]: 이전 단계 validate PASS 없이 다음 단계 진입 불가
- **validate-retry-limit** [validation]: 단계당 최대 3회 재시도. 초과 시 BLOCKED
- **evidence-based-scoring** [validation]: 모든 점수 판정에 file:line 근거 필수. 근거 없는 점수 무효

## Loop

- **wip-file-state-detection** [loop]: wip 파일 존재 여부로 재개 지점 판단. missing부터 실행
- **cleanup-after-completion** [loop]: 5단계 모두 완료 후 cleanup.sh로 wip/bak 파일 제거
- **no-commit-policy** [loop]: implement 단계에서 커밋 금지. 사용자 직접 확인 후 커밋

## Heritage

- **heritage-accumulation** [heritage]: ADR(결정) + FMEA(실패 패턴)로 경험 축적. 루프마다 갱신
- **detect-fix-prevent** [heritage]: FMEA 항목은 탐지→수정→예방 3단계 구조

## Verification

- **vf-layer** [loop, heritage]: VF 단계 도입. 점수 delta + heritage 자동 업데이트로 피드백 루프 폐합
- **scoreboard-tracking** [heritage]: scoreboard.md로 루프별 점수 영속 추적. append-only
- **archive-before-cleanup** [loop]: cleanup 전 logs/archive/loop-NNN/에 wip 파일 보존. 기억 소실 방지
- **difficulty-governance** [loop, governance]: 난이도 점수 + 최소 쿼터로 easy-pick 편향 방어
