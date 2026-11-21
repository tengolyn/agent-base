# AgentBase

My personal agentic development environment: templates to drop into any project with one command. Roles, skills, a file-based task queue and a build loop. **Local only:** the project repo holds application code; the whole setup is git-ignored.

## Use
From the project root:
```bash
curl -fsSL https://raw.githubusercontent.com/tengolyn/agent-base/master/install.sh | bash -s -- base
```
Or from a clone: `./install.sh base --target /path/to/project` (`--dry-run` shows what it would do).

- Target must be a git repo. Copies `template/base/` into it. Never overwrites an existing file; lists skipped ones for a manual merge.
- Writes the template's `exclude` lines (`/AGENTS.md`, `/CLAUDE.md`, `/.agents`, `/.claude`, `.env`) to `.git/info/exclude`. Why: ignored without touching the project's `.gitignore`; shared by all worktrees.
- Warns when a setup file is already tracked (`git rm -r --cached <path>`, then commit).
- Keep a private copy of the filled-in setup: git does not back it up.
- Templates: `base` only for now.

Then (the installer prints these too):
1. Fill every `<…>` in `AGENTS.md` (Product, Repo map, Commands with the Validate line, protected paths). Why: roles, skills and the loop read project facts only from there.
2. `git config core.hooksPath .agents/githooks`. Why: blocks direct pushes to the default branch.
3. Write `.agents/product-checklist.md` (one checkable box ≈ one PR) and fill or delete the project hard limits in `.agents/prompts/build_loop.md`. Why: the loop works through the boxes and stops at none open.
4. `.agents/scripts/check_layout.sh`. Why: confirms pointers and listings are intact.
5. Optional: `.agents/scripts/build_loop.sh --dry-run`, then start it yourself. Runs with `--dangerously-skip-permissions`: dev container or sandbox only.

## Contents of `template/base/`
| Path | What |
|---|---|
| `AGENTS.md` | single source of truth (tool-agnostic): project template, rules, commit/PR format |
| `CLAUDE.md` | points Claude at `AGENTS.md` |
| `.agents/README.md` | layout, task rules, holds |
| `.agents/product-checklist.md` | definition-of-done template the build loop works through |
| `.agents/agents/` | roles: `lead`, `builder`, `reviewer` |
| `.agents/skills/` | `add_task`, `work_task`, `delegate_task`, `verify_result`, `create_skill`, `create_agent` |
| `.agents/templates/task.md`, `.agents/state/tasks/` | task queue; folder = status |
| `.agents/scripts/`, `.agents/prompts/` | build loop, layout check, `worktree.sh` (task worktree with the ignored setup linked in) |
| `.agents/githooks/pre-push` | refuses direct pushes to the default branch |
| `.claude/skills/`, `.claude/agents/` | thin Claude Code pointers to the above |
| `exclude` | not copied: the installer writes its lines to `.git/info/exclude` |

## Maintaining AgentBase
Read before changing this repo. Why: files here either ship into projects or stay here, and mixing them breaks installs.

| Path | Ships to projects? | Role |
|---|---|---|
| `template/<name>/` | yes (all but `exclude`) | one template; `base` = the core setup |
| `template/<name>/exclude` | written to the project's `.git/info/exclude` | ignore patterns; a new top-level setup path goes here (no trailing slash: worktree symlinks) |
| `install.sh` | no | copies a template, writes exclude lines, lists skipped files, warns on tracked setup |
| `README.md`, `.gitignore` | no | this repo's own docs and ignores |

- **Project repo = application code only (owner rule, 2026-11-21):** everything a template ships stays git-ignored in the project. Keep new setup files under the existing four top-level paths, or add the path to `exclude` and to `worktree.sh`.
- Project-specific facts never go in shipped files; use `<…>` placeholders in `AGENTS.md`. Why: one setup for every project.
- A shipped file is never overwritten in a project. A change to an existing file needs a manual merge note in the PR `risk:`.
- New template: only on the owner's decision (stack templates deferred, 2026-11-21).
- Owner request unclear (file name, which file, ship or not): restate the understanding and wait for OK before editing. Why: misread requests here reached `master` (#1 deleted `.example.gitignore`; #1-#3 tracked the setup the owner wanted ignored).
- Validate: `template/base/.agents/scripts/check_layout.sh`, then `./install.sh base --target <fresh git repo>`; there: `check_layout.sh`, `git status` clean, `worktree.sh T-001` + `--remove T-001`, `build_loop.sh --dry-run`.
