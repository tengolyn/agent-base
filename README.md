# AgentBase

My personal agentic development environment: one fixed setup to drop into any project. Roles, skills, a file-based task queue and a build loop, tracked in the project's repo.

## Use
```bash
git clone --depth 1 git@github.com:tengolyn/agent-base.git /tmp/agentbase && rsync -a --ignore-existing --exclude=/.git --exclude=/README.md --exclude=/.gitignore /tmp/agentbase/ ./
```
Copies everything except `.git`, `README.md`, `.gitignore`. `--ignore-existing` never overwrites existing files.

Then:
1. `cat .example.gitignore >> .gitignore && rm .example.gitignore`. Why: task files, loop logs, `.env` and Claude local files stay out of git; the setup itself stays tracked.
2. Fill every `<…>` in `AGENTS.md` (Product, Repo map, Commands with the Validate line, protected paths). Why: roles, skills and the loop read project facts only from there.
3. `git config core.hooksPath .githooks`. Why: blocks direct pushes to the default branch.
4. Write `docs/product-checklist.md` (one checkable box ≈ one PR) and fill or delete the project hard limits in `.agents/prompts/build_loop.md`. Why: the loop works through the boxes and stops at none open.
5. `.agents/scripts/check_layout.sh`. Why: confirms pointers and listings are intact.
6. Optional: `.agents/scripts/build_loop.sh --dry-run`, then start it yourself. Runs with `--dangerously-skip-permissions`: dev container or sandbox only.

## Contents
| Path | What |
|---|---|
| `AGENTS.md` | single source of truth (tool-agnostic): project template, rules, commit/PR format |
| `CLAUDE.md` | points Claude at `AGENTS.md` |
| `.agents/README.md` | layout, task rules, holds |
| `.agents/agents/` | roles: `lead`, `builder`, `reviewer` |
| `.agents/skills/` | `add_task`, `work_task`, `delegate_task`, `verify_result`, `create_skill`, `create_agent` |
| `.agents/templates/task.md`, `.agents/state/tasks/` | task queue; folder = status |
| `.agents/scripts/`, `.agents/prompts/` | build loop, layout check |
| `.claude/skills/`, `.claude/agents/` | thin Claude Code pointers to the above |
| `.example.gitignore` | lines to append to the project's `.gitignore` (local agent files only) |
| `.githooks/pre-push` | refuses direct pushes to the default branch |
| `docs/product-checklist.md` | definition-of-done template the build loop works through |

## Maintaining AgentBase
Read before changing this repo. Why: files here either ship into projects or stay here, and mixing them breaks installs.

| File | Ships to projects? | Role |
|---|---|---|
| `README.md` | no (`--exclude`) | install steps, this section |
| `.gitignore` | no (`--exclude`) | this repo's own ignores; superset of `.example.gitignore` |
| `.example.gitignore` | yes | the ignore lines a project appends; new local files agent work creates go here (and in `.gitignore`) |
| everything else | yes, never overwrites existing files | the setup |

- Project-specific facts never go in shipped files; use `<…>` placeholders in `AGENTS.md`. Why: one setup for every project.
- A shipped file is never overwritten in a project (`--ignore-existing`). A change to an existing file needs a manual merge note in the PR `risk:`.
- Owner request unclear (file name, which file, ship or not): restate the understanding and wait for OK before editing. Why: a misread request here reached `master` once (`.example.gitignore` deleted in #1).
- Validate: `.agents/scripts/check_layout.sh`, then the README install into an empty repo plus `git check-ignore` on the `.example.gitignore` paths.

