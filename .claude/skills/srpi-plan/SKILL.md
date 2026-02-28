---
name: srpi-plan
description: 리서치 결과를 기반으로 우선순위 정렬된 구현 계획을 수립하여 logs/plan-wip.md를 생성한다.
disable-model-invocation: true
---

`logs/research-wip.md`에서 추천 방안을 추출하고, 임팩트/난이도 기반으로 태스크를 분해하여 [template.md](template.md) 형식으로 `logs/plan-wip.md`에 기록한다.

태스크당 파일 1-3개. C#-E# 연결 유지. 검증 방법 구체적으로. 파일 없으면 중단.

완료 후 `bash .claude/skills/srpi-plan/validate.sh` 실행.
