---
name: srpi-research
description: 평가 결과를 근거 기반으로 분석하여 logs/research-wip.md를 생성한다.
disable-model-invocation: true
---

`logs/quest-wip.md`에서 7점 미만 영역을 추출하고, [방법론](../../context/methodology.md)에 따라 근거 수집 + 반증 루프를 실행하여 [template.md](template.md) 형식으로 `logs/research-wip.md`에 기록한다.

[공통 규칙](../../context/conventions.md) 준수. 파일 없으면 중단.

완료 후 `bash .claude/skills/srpi-research/validate.sh` 실행.
