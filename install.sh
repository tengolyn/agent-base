#!/usr/bin/env bash
# Install an AgentBase template (template/<name>/) into a project.
# Never overwrites an existing file: skipped files are listed for a manual merge.
# The template's exclude file is not copied; its missing lines go to the project's .git/info/exclude (never committed),
# so the agentic setup stays out of the project repo.
#
# Usage: install.sh <template> [--target DIR] [--dry-run]
#   from a clone:  ./install.sh base --target /path/to/project
#   remote:        curl -fsSL https://raw.githubusercontent.com/tengolyn/agent-base/master/install.sh | bash -s -- base
set -euo pipefail

repo_url=${AGENTBASE_REPO:-https://github.com/tengolyn/agent-base.git}  # override for testing
usage() { sed -n '2,8p' "${BASH_SOURCE[0]:-/dev/null}" 2>/dev/null | sed 's/^# \{0,1\}//'; }

name="" target=. dry=0
while [ $# -gt 0 ]; do
  case "$1" in
    --target) target="$2"; shift ;;
    --dry-run) dry=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "unknown option $1 (see --help)" >&2; exit 2 ;;
    *) [ -z "$name" ] || { echo "one template only" >&2; exit 2; }; name="$1" ;;
  esac
  shift
done

# source: the clone this script sits in, else a fresh shallow clone (piped from curl)
here=$(cd "$(dirname "${BASH_SOURCE[0]:-.}")" 2>/dev/null && pwd || true)
if [ -n "$here" ] && [ -d "$here/template" ]; then
  root=$here
else
  root=$(mktemp -d)
  trap 'rm -rf "$root"' EXIT
  git clone -q --depth 1 "$repo_url" "$root"
fi

available=$(cd "$root/template" && ls -d -- */ 2>/dev/null | tr -d / | tr '\n' ' ')
if [ -z "$name" ]; then echo "usage: install.sh <template> [--target DIR] [--dry-run]; templates: $available" >&2; exit 2; fi
src="$root/template/$name"
[ -d "$src" ] || { echo "no template '$name'; templates: $available" >&2; exit 2; }
[ -d "$target" ] || { echo "target $target is not a directory" >&2; exit 2; }
target=$(cd "$target" && pwd)
gitdir=$(git -C "$target" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) \
  || { echo "target $target is not a git repo (git init first)" >&2; exit 2; }
exclude="$gitdir/info/exclude"
[ "$dry" = 1 ] && echo "dry run: nothing is written"

copied=0 skipped=()
while IFS= read -r -d '' f; do
  rel=${f#"$src"/}
  [ "$rel" = exclude ] && continue
  if [ -e "$target/$rel" ]; then skipped+=("$rel"); continue; fi
  if [ "$dry" = 0 ]; then mkdir -p "$(dirname "$target/$rel")" && cp -p "$f" "$target/$rel"; fi
  copied=$((copied + 1))
done < <(find "$src" -type f -print0 | sort -z)

added=()
if [ -f "$src/exclude" ]; then
  while IFS= read -r l; do
    case "$l" in ''|'#'*) continue ;; esac
    grep -qxF -- "$l" "$exclude" 2>/dev/null || added+=("$l")
  done < "$src/exclude"
  if [ "$dry" = 0 ] && [ ${#added[@]} -gt 0 ]; then
    mkdir -p "$(dirname "$exclude")"
    { [ -s "$exclude" ] && [ -n "$(tail -c1 "$exclude")" ] && echo; \
      echo "# AgentBase ($name): agentic setup, local only"; printf '%s\n' "${added[@]}"; } >> "$exclude"
  fi
fi
tracked=$(git -C "$target" ls-files -- AGENTS.md CLAUDE.md .agents .claude | head -5 | tr '\n' ' ')

echo "template $name -> $target"
echo "copied: $copied file(s)"
echo ".git/info/exclude: ${#added[@]} line(s) added"
[ -z "$tracked" ] || echo "warning: already tracked, so not ignored: $tracked(git rm -r --cached <path>, then commit)"
if [ ${#skipped[@]} -gt 0 ]; then
  echo "skipped (already exist, merge by hand): ${#skipped[@]}"
  printf '  %s\n' "${skipped[@]}"
fi
cat <<'EOF'
next:
  1. fill every <…> in AGENTS.md (Product, Repo map, Commands with the Validate line, protected paths)
  2. git config core.hooksPath .agents/githooks
  3. write .agents/product-checklist.md; fill or delete the project hard limits in .agents/prompts/build_loop.md
  4. .agents/scripts/check_layout.sh
EOF
