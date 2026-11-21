# AgentBase

My personal agentic development environment: one fixed setup to drop into any project. Roles, skills, a file-based task queue and a build loop, tracked in the project's repo.

## Use
```bash
git clone --depth 1 git@github.com:tengolyn/agent-base.git /tmp/agentbase && rsync -a --ignore-existing --exclude=/.git --exclude=/README.md --exclude=/.gitignore /tmp/agentbase/ ./
```
Copies everything except `.git`, `README.md`, `.gitignore`. `--ignore-existing` never overwrites existing files.

Then:
1. Append AgentBase's `.gitignore` lines (secrets, queue, loop logs) to the project's `.gitignore`. Why: task files and loop logs change constantly and stay local; `.env` never reaches git.
2. `.env.example`: if the project already has one, the install skipped it; append the "Agentic development" section and move the app keys under "App". Why: one file lists every key a fresh clone needs.
3. Fill every `<…>` in `AGENTS.md` (Product, Repo map, Commands with the Validate line, protected paths). Why: roles, skills and the loop read project facts only from there.
4. `git config core.hooksPath .githooks`. Why: blocks direct pushes to the default branch.
5. Write `docs/product-checklist.md` (one checkable box ≈ one PR) and fill or delete the project hard limits in `.agents/prompts/build_loop.md`. Why: the loop works through the boxes and stops at none open.
6. `.agents/scripts/check_layout.sh`. Why: confirms pointers and listings are intact.
7. Optional: `.agents/scripts/build_loop.sh --dry-run`, then start it yourself. Runs with `--dangerously-skip-permissions`: dev container or sandbox only.

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
| `.env.example` | env keys: app section (placeholder), agentic development section (build loop defaults) |
| `.githooks/pre-push` | refuses direct pushes to the default branch |
| `docs/product-checklist.md` | definition-of-done template the build loop works through |
