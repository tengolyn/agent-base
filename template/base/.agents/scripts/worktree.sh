#!/usr/bin/env bash
# Task worktree with the agent setup linked in. The setup is git-ignored, so `git worktree add` alone gives a
# checkout without AGENTS.md, skills or roles. Links share one setup and one task queue with the main checkout.
#
# Usage: .agents/scripts/worktree.sh T-NNN           create ../<repo>-wt/T-NNN on new branch task/T-NNN from origin's default branch
#        .agents/scripts/worktree.sh --remove T-NNN  remove it (the branch stays)
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
setup=(AGENTS.md CLAUDE.md .agents .claude)
remove=0
[ "${1:-}" = --remove ] && { remove=1; shift; }
id=${1:?usage: worktree.sh [--remove] T-NNN}
wt="$(dirname "$root")/$(basename "$root")-wt/$id"

if [ "$remove" = 1 ]; then
  dirty=$(git -C "$wt" status --porcelain)
  [ -z "$dirty" ] || { echo "$wt has uncommitted changes; commit or discard them first:" >&2; echo "$dirty" >&2; exit 1; }
  for p in "${setup[@]}"; do [ -L "$wt/$p" ] && rm "$wt/$p"; done
  git worktree remove "$wt"
  echo "removed $wt"
  exit 0
fi

base=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##') || true
base=${base:-main}
git fetch -q origin
git worktree add -q -b "task/$id" "$wt" "origin/$base"
for p in "${setup[@]}"; do [ -e "$p" ] && ln -s "$root/$p" "$wt/$p"; done
echo "$wt (branch task/$id from origin/$base, setup linked)"
