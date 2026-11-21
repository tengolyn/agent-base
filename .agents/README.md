# .agents: how AI agents work on this repo

Agents (Claude Code sessions, sub-agents, build loop) read [AGENTS.md](../AGENTS.md) first, then this file.

| folder | what | tracked |
|---|---|---|
| `agents/<role>/AGENT.md` | roles: `lead`, `builder`, `reviewer` | yes |
| `skills/<name>/SKILL.md` | procedures: `work_task`, `add_task`, `delegate_task`, `verify_result`, `create_skill`, `create_agent` | yes |
| `templates/` | `task.md` | yes |
| `prompts/build_loop.md`, `scripts/build_loop.sh` | the build loop: fresh headless Claude sessions, one checklist item each, until [docs/product-checklist.md](../docs/product-checklist.md) has no open box | yes (logs in `state/build-loop/` are local) |
| `scripts/check_layout.sh` | checks pointers resolve, every skill and role is listed, task folders exist | yes |
| `state/tasks/<status>/T-NNN.md` | the task queue; folder = status | skeleton only; task files are local |

Claude Code finds the skills through `.claude/skills/<name>/SKILL.md` and the roles through `.claude/agents/<role>.md`. Both are pointers to the files here.

## Tasks

- **One task = one file** `T-NNN.md` (copy `templates/task.md`). The folder is its status: `planned/` → `active/` → `done/` or `dropped/`. Moving the file changes the status; also update `status:` and `updated:` inside it.
- **Id:** the highest `T-NNN` across all four folders, plus one.
- **Claim:** move it to `active/` and set `owner:` (session or agent name). An `active/` task with an owner belongs to that owner; don't touch it. Why: parallel agents must not do the same work twice.
- **Pick order:** `planned/` tasks whose `depends:` are all in `done/`, then lowest `priority`, then lowest id.
- **Done** only with evidence in the `## Log` (PR number, merged sha, test count). Why: a task closed on a claim hides gaps.
- **Code tasks** run on a branch `task/T-NNN` (worktree `../<repo>-wt/T-NNN` when agents work in parallel), PR per [AGENTS.md](../AGENTS.md) Development loop.
- Task files are local (gitignored). Why: queue state changes on every claim and would conflict across branches. Keep a private copy.

## Holds

- The owner can pause anything by saying so. Record it as a `## Holds` line in the affected task, or as a `hold` task in `active/` with `owner: owner`. Agents never lift a hold themselves.
- An issue the owner raised about an output blocks approving that output (and its siblings from the same source) until fixed and checked on the final artifact. Why: ruling out one cause is not a fix; the owner judges the result.
- Standing gates (always on): outward-facing actions and protected paths per [AGENTS.md](../AGENTS.md) Engineering rules.
