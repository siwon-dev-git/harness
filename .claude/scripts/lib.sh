#!/bin/bash
# SRPI 검증 공통 함수
set -euo pipefail

LOGS_DIR="logs"
ERRORS=()
_LIB_START=$(date +%s)

# 5기준 공유 정의
SRPI_CRITERIA=("코드 품질" "아키텍처" "테스트" "보안" "성능")

err() { ERRORS+=("FAIL: $1"); }
ok()  { echo "  OK: $1"; }

check_file() {
  [[ -f "$1" ]] && ok "$1 exists" || { err "$1 missing"; return 1; }
}

check_pattern() {
  grep -qE "$2" "$1" 2>/dev/null && ok "$3" || err "$3 -- pattern not found"
}

check_count() {
  local c=0
  c=$(grep -cE "$2" "$1" 2>/dev/null) || true
  [[ "$c" -ge "$3" ]] && ok "$4 ($c)" || err "$4 -- need $3, found $c"
}

check_no_pattern() {
  grep -qE "$2" "$1" 2>/dev/null && err "$3 -- pattern should NOT exist" || ok "$3"
}

check_section_order() {
  local file="$1"; shift
  local prev_line=0
  for section in "$@"; do
    local line
    line=$(grep -nE "$section" "$file" 2>/dev/null | head -1 | cut -d: -f1) || true
    if [[ -z "$line" ]]; then
      err "section '$section' not found in $file"
      return
    fi
    if [[ "$line" -le "$prev_line" ]]; then
      err "section '$section' (L$line) out of order (expected after L$prev_line)"
      return
    fi
    prev_line="$line"
  done
  ok "section order correct"
}

check_range() {
  # Usage: check_range <file> <grep_pattern> <min> <max> <label>
  # Extracts all numbers matching pattern and verifies each is within [min, max]
  local file="$1" pattern="$2" min="$3" max="$4" label="$5"
  local matches
  matches=$(grep -oE "$pattern" "$file" 2>/dev/null) || true
  if [[ -z "$matches" ]]; then
    err "$label -- no numbers found"
    return
  fi
  local out_of_range=0
  while IFS= read -r m; do
    local n="${m//[!0-9]/}"
    [[ -z "$n" ]] && continue
    if [[ "$n" -lt "$min" || "$n" -gt "$max" ]]; then
      out_of_range=$((out_of_range + 1))
    fi
  done <<< "$matches"
  if [[ "$out_of_range" -gt 0 ]]; then
    err "$label -- $out_of_range values outside [$min, $max]"
  else
    ok "$label"
  fi
}

check_all_criteria() {
  # Usage: check_all_criteria <file>
  # Checks all 5 SRPI criteria have score pattern (N/10)
  local file="$1"
  for c in "${SRPI_CRITERIA[@]}"; do
    check_pattern "$file" "## ${c}.*[0-9]+/10" "${c} 섹션+점수"
  done
}

check_difficulty_sum() {
  # Usage: check_difficulty_sum <file> <label>
  # Verifies L+M+H count == countable tasks
  # Subtask-aware: H parents with ### T#.N subtasks → count subtasks, not parent
  local file="$1" label="$2"
  local subtask_count
  subtask_count=$(grep -cE '^### T[0-9]+\.[0-9]+' "$file" 2>/dev/null) || true

  local task_count
  if [[ "$subtask_count" -gt 0 ]]; then
    local parent_with_subs total_parents standalone
    parent_with_subs=$(grep -oE '^### (T[0-9]+)\.' "$file" 2>/dev/null \
      | grep -oE 'T[0-9]+' | sort -u | wc -l | tr -d ' ') || true
    total_parents=$(grep -cE '^## T[0-9]+' "$file" 2>/dev/null) || true
    standalone=$((total_parents - parent_with_subs))
    task_count=$((standalone + subtask_count))
  else
    task_count=$(grep -cE '^## T[0-9]+' "$file" 2>/dev/null) || true
  fi

  local l_count m_count h_count
  l_count=$(grep -oE 'L: ?[0-9]+개' "$file" | grep -oE '[0-9]+' | head -1) || true
  m_count=$(grep -oE 'M: ?[0-9]+개' "$file" | grep -oE '[0-9]+' | head -1) || true
  h_count=$(grep -oE 'H: ?[0-9]+개' "$file" | grep -oE '[0-9]+' | head -1) || true
  l_count=${l_count:-0}; m_count=${m_count:-0}; h_count=${h_count:-0}
  local sum=$((l_count + m_count + h_count))

  if [[ "$task_count" -eq 0 ]]; then
    err "$label -- no tasks found"
  elif [[ "$sum" -ne "$task_count" ]]; then
    err "$label -- L($l_count)+M($m_count)+H($h_count)=$sum != tasks($task_count)"
  else
    ok "$label (L:$l_count M:$m_count H:$h_count = $task_count tasks)"
  fi
}

check_dependency_dag() {
  # Usage: check_dependency_dag <file> <label>
  # Validates: (a) all 선행 T# refs exist, (b) ≥1 root, (c) no cycles (Kahn's)
  local file="$1" label="$2"

  # 1. Extract all task IDs (## T# and ### T#.#)
  local all_ids
  all_ids=$(grep -E '^##+ T[0-9]+' "$file" 2>/dev/null \
    | grep -oE 'T[0-9]+(\.[0-9]+)?' | sort -u) || true
  if [[ -z "$all_ids" ]]; then
    err "$label -- no tasks found"; return
  fi
  local total
  total=$(echo "$all_ids" | wc -l | tr -d ' ')

  # 2. Parse 선행 fields → "CHILD:PARENT" edge list
  local edges="" has_root=0 cur=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^##[[:space:]]+(T[0-9]+) ]]; then
      cur="${BASH_REMATCH[1]}"
    elif [[ -n "$cur" && "$line" == *선행* ]]; then
      if [[ "$line" == *없음* ]]; then
        has_root=1
      else
        local refs
        refs=$(echo "$line" | grep -oE 'T[0-9]+(\.[0-9]+)?') || true
        for r in $refs; do
          echo "$all_ids" | grep -qxF "$r" \
            || err "$label -- $cur references non-existent $r"
          edges="${edges}${cur}:${r}"$'\n'
        done
      fi
      cur=""
    fi
  done < "$file"

  # 3. Root invariant
  if [[ "$has_root" -eq 0 ]]; then
    err "$label -- no root task (deadlock)"; return
  fi

  # 4. Kahn's algorithm — iteratively resolve tasks with satisfied deps
  local resolved="" changed=1
  while [[ "$changed" -eq 1 ]]; do
    changed=0
    while IFS= read -r t; do
      [[ -z "$t" ]] && continue
      echo "$resolved" | grep -qxF "$t" && continue
      local blocked=0 deps
      deps=$(echo "$edges" | grep "^${t}:" | cut -d: -f2) || true
      for d in $deps; do
        echo "$resolved" | grep -qxF "$d" || { blocked=1; break; }
      done
      [[ "$blocked" -eq 0 ]] && { resolved="${resolved}${t}"$'\n'; changed=1; }
    done <<< "$all_ids"
  done

  local resolved_count
  resolved_count=$(echo "$resolved" | grep -c '.' 2>/dev/null) || true
  [[ "$resolved_count" -lt "$total" ]] \
    && err "$label -- cycle detected" \
    || ok "$label"
}

check_h_expansion() {
  # Usage: check_h_expansion <file> <label>
  # Validates: H tasks have >= 2 subtasks, all M or L
  local file="$1" label="$2"
  local violations=0
  while IFS= read -r line; do
    if [[ "$line" =~ ^##[[:space:]]+(T[0-9]+).*난이도:[[:space:]]*H ]]; then
      local tid="${BASH_REMATCH[1]}"
      local sub_count
      sub_count=$(grep -cE "^### ${tid}\.[0-9]+" "$file" 2>/dev/null) || true
      if [[ "$sub_count" -lt 2 ]]; then
        err "$label -- $tid (H) needs >= 2 subtasks, found $sub_count"
        violations=$((violations + 1))
      fi
      local h_subs
      h_subs=$(grep -E "^### ${tid}\.[0-9]+" "$file" 2>/dev/null \
        | grep -c '난이도:[[:space:]]*H') || true
      if [[ "$h_subs" -gt 0 ]]; then
        err "$label -- $tid has H-difficulty subtasks"
        violations=$((violations + 1))
      fi
    fi
  done < "$file"
  [[ "$violations" -eq 0 ]] && ok "$label"
}

check_scoreboard_delta() {
  # Usage: check_scoreboard_delta <scoreboard_file> <max_drop> <label>
  # Checks that the latest scoreboard avg didn't drop more than max_drop vs previous
  local file="$1" max_drop="$2" label="$3"
  local rows
  rows=$(grep -E '^\| [0-9]' "$file" 2>/dev/null) || true
  local row_count
  row_count=$(echo "$rows" | grep -c '.' 2>/dev/null) || true
  if [[ "$row_count" -lt 2 ]]; then
    ok "$label (< 2 rows, skip)"
    return
  fi
  # 헤더에서 "평균" 컬럼 인덱스 동적 추출 (하드코딩 $9 제거)
  local avg_col
  avg_col=$(head -5 "$file" | grep -E '^\|.*평균' | awk -F'|' '{for(i=1;i<=NF;i++) if($i~/평균/) print i}') || true
  if [[ -z "$avg_col" ]]; then
    ok "$label (avg column not found, skip)"
    return
  fi
  # 동적 컬럼 인덱스로 평균값 추출
  local prev_avg latest_avg
  prev_avg=$(echo "$rows" | tail -2 | head -1 | awk -F'|' -v col="$avg_col" '{gsub(/ /,"",$col); print $col}') || true
  latest_avg=$(echo "$rows" | tail -1 | awk -F'|' -v col="$avg_col" '{gsub(/ /,"",$col); print $col}') || true
  if [[ -z "$prev_avg" || -z "$latest_avg" ]]; then
    ok "$label (avg parse skip)"
    return
  fi
  # Compare using bc for decimal
  local drop
  drop=$(echo "scale=1; $prev_avg - $latest_avg" | bc 2>/dev/null) || true
  local is_drop
  is_drop=$(echo "$drop > $max_drop" | bc 2>/dev/null) || true
  if [[ "$is_drop" == "1" ]]; then
    err "$label -- avg dropped $drop (prev=$prev_avg, latest=$latest_avg, max=$max_drop)"
  else
    ok "$label (prev=$prev_avg, latest=$latest_avg)"
  fi
}

result() {
  local elapsed=$(( $(date +%s) - _LIB_START ))
  echo ""
  if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo "FAIL: ${#ERRORS[@]} errors (${elapsed}s)"
    printf '  %s\n' "${ERRORS[@]}"
    exit 1
  fi
  echo "PASS (${elapsed}s)"
}
