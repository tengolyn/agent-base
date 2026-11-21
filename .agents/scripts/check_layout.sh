#!/usr/bin/env bash
# Checks the .agents/ layout: every skill and role has its Claude pointer (where needed), pointers resolve and match,
# every skill and role is listed in .agents/README.md, task folders and template exist. Exit 1 on any failure.
set -uo pipefail
cd "$(dirname "$0")/../.."
fail=0
err() { echo "check_layout: $*" >&2; fail=1; }
readme=.agents/README.md
[ -f "$readme" ] || { err "missing $readme"; exit 1; }

links_resolve() {  # every relative markdown link in $1 points at an existing file
  local f=$1 dir; dir=$(dirname "$f")
  grep -o '](\([^)#]*\))' "$f" | sed 's/^](//; s/)$//' | grep -v '^https\?:' | while read -r l; do
    [ -e "$dir/$l" ] || echo "$f: broken link $l"
  done
}

for s in .agents/skills/*/SKILL.md; do
  n=$(basename "$(dirname "$s")"); p=.claude/skills/$n/SKILL.md
  [ -f "$p" ] || { err "skill $n: missing pointer $p"; continue; }
  grep -qx "name: $n" "$p" || err "$p: frontmatter name is not $n"
  grep -q '^description: .\+' "$p" || err "$p: no description"
  grep -q "\`$n\`" "$readme" || err "skill $n: not listed in $readme"
done
for p in .claude/skills/*/SKILL.md; do
  [ -e "$p" ] || continue
  n=$(basename "$(dirname "$p")"); [ -f ".agents/skills/$n/SKILL.md" ] || err "$p: no .agents/skills/$n"
done
for a in .agents/agents/*/AGENT.md; do
  [ -e "$a" ] || continue
  n=$(basename "$(dirname "$a")"); grep -q "\`$n\`" "$readme" || err "role $n: not listed in $readme"
done
for p in .claude/agents/*.md; do
  [ -e "$p" ] || continue
  n=$(basename "$p" .md); [ -f ".agents/agents/$n/AGENT.md" ] || err "$p: no .agents/agents/$n"
done
for f in .claude/skills/*/SKILL.md .claude/agents/*.md .agents/README.md; do
  [ -e "$f" ] || continue
  out=$(links_resolve "$f"); [ -z "$out" ] || err "$out"
done
for st in planned active done dropped; do [ -d ".agents/state/tasks/$st" ] || err "missing .agents/state/tasks/$st"; done
t=.agents/templates/task.md
for k in id title status priority owner branch depends; do grep -q "^$k:" "$t" 2>/dev/null || err "$t: missing $k"; done

[ "$fail" = 0 ] && echo "check_layout: ok"
exit "$fail"
