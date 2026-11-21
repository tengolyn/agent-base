#!/usr/bin/env bash
# Build loop: run headless Claude Code again and again until .agents/product-checklist.md has no open box.
# Each iteration is one fresh `claude -p` session with .agents/prompts/build_loop.md: it finishes one checklist item
# through a PR, then exits. Never started automatically.
#
# The checklist is local (git-ignored); sessions tick it after their PR merges. Progress = origin's default branch
# (origin/HEAD; fallback main) moved or the open count dropped.
#
# Usage: .agents/scripts/build_loop.sh [--max N] [--stall N] [--timebox MIN] [--model M] [--budget USD] [--once] [--dry-run]
#   --max N        iterations at most (default 40)
#   --stall N      stop after N iterations in a row with no progress on the default branch (default 3)
#   --timebox MIN  kill an iteration after MIN minutes (default 120)
#   --model M      claude model (default opus)
#   --budget USD   per-iteration spend cap passed to claude (--max-budget-usd); default none
# Stop: touch .agents/state/BUILD_OFF  (checked before every iteration)  or Ctrl-C / kill the pid in .agents/state/build-loop/pid
#
# Runs with --dangerously-skip-permissions: the session may run any command without asking. The prompt's hard limits
# are instructions, not enforcement. Run it only in a dev container or sandbox, never on a machine with data you can't lose.
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"
prompt_file=.agents/prompts/build_loop.md
checklist=.agents/product-checklist.md
state=.agents/state/build-loop
stop_file=.agents/state/BUILD_OFF

base=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##') || true
base=${base:-main}

max=40 stall_max=3 timebox=120 model=opus budget="" once=0 dry=0
while [ $# -gt 0 ]; do
  case "$1" in
    --max) max="$2"; shift ;;
    --stall) stall_max="$2"; shift ;;
    --timebox) timebox="$2"; shift ;;
    --model) model="$2"; shift ;;
    --budget) budget="$2"; shift ;;
    --once) once=1 ;;
    --dry-run) dry=1 ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "unknown option $1 (see --help)" >&2; exit 2 ;;
  esac
  shift
done

cmd=(timeout "${timebox}m" claude -p --dangerously-skip-permissions --model "$model" --output-format json)
[ -n "$budget" ] && cmd+=(--max-budget-usd "$budget")

open_items() {  # open boxes in the local checklist; "missing" when there is none
  [ -f "$checklist" ] || { echo missing; return; }
  grep -c '^- \[ \]' "$checklist" || true
}

if [ "$dry" = 1 ]; then
  git fetch -q origin || true
  printf 'open items in %s: %s (default branch %s)\n' "$checklist" "$(open_items)" "$base"
  printf 'cd %q && %s < %q\n' "$root" "$(printf '%q ' "${cmd[@]}")" "$prompt_file"
  exit 0
fi

command -v claude >/dev/null || { echo "claude CLI not found" >&2; exit 1; }
[ -f "$prompt_file" ] || { echo "missing $prompt_file" >&2; exit 1; }
mkdir -p "$state"
exec 9>"$state/lock"
flock -n 9 || { echo "another build loop is running" >&2; exit 1; }
echo $$ > "$state/pid"
trap 'rm -f "$state/pid"' EXIT
summary="$state/summary.log"

i=0 stall=0
while :; do
  if [ -e "$stop_file" ]; then echo "stop file $stop_file present: stopping"; break; fi
  git fetch -q origin || echo "warning: git fetch failed"
  left=$(open_items)
  if [ "$left" = missing ]; then echo "missing $checklist: write it first" >&2; exit 1; fi
  if [ "$left" = 0 ]; then echo "checklist complete: done"; break; fi
  if [ "$i" -ge "$max" ]; then echo "reached --max $max iterations: stopping"; break; fi
  i=$((i + 1))
  # start each iteration from a clean, current default branch when the tree allows it; leftovers are the session's to resolve
  if [ -z "$(git status --porcelain --untracked-files=no)" ]; then
    git switch -q "$base" && git pull -q --ff-only origin "$base" || echo "warning: could not update $base"
  fi
  main_before=$(git rev-parse origin/$base)
  ts=$(date -u +%Y%m%dT%H%M%SZ)
  log="$state/$ts-$i.json"
  printf '%s iteration %s: %s open item(s), %s %s\n' "$ts" "$i" "$left" "$base" "${main_before:0:7}" | tee -a "$summary"
  rc=0
  "${cmd[@]}" < "$prompt_file" > "$log" 2> "$log.err" || rc=$?
  line=$(python3 -c 'import json,sys
try:
    d = json.load(open(sys.argv[1]))
    r = str(d.get("result", "")).strip().splitlines()
    loop = [x for x in r if x.startswith("LOOP:")]
    print((loop[-1] if loop else (r[-1] if r else "(no result)"))[:300], "| cost", d.get("total_cost_usd"))
except Exception as e:
    print("(unreadable result:", e, ")")' "$log")
  git fetch -q origin || true
  main_after=$(git rev-parse origin/$base)
  left_after=$(open_items)
  printf '  rc %s  %s  open %s -> %s  %s %s -> %s\n' "$rc" "$line" "$left" "$left_after" "$base" "${main_before:0:7}" "${main_after:0:7}" \
    | tee -a "$summary"
  case "$line" in LOOP:\ nothing-left*) echo "session reports nothing left: stopping"; break ;; esac
  if [ "$main_after" = "$main_before" ] && [ "$left_after" = "$left" ]; then
    stall=$((stall + 1))
    if [ "$stall" -ge "$stall_max" ]; then echo "no progress for $stall iteration(s): stopping"; break; fi
  else
    stall=0
  fi
  [ "$once" = 1 ] && break
done
echo "build loop finished after $i iteration(s). Summary: $summary"
