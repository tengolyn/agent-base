# AGENTS: <project> guide

Single source of truth for anyone (person or AI) working on this repo. Other files reference it; nothing here is duplicated elsewhere. Fill every `<…>` on install.

## Product

- **What:** <one line: what it does, for whom>
- **Flow:** <input → steps → output>
- **Shape:** <single user / hosted / library; what must stay easy to change later>
- **Quality bar:** <what "good" means to the owner, checkable>
- Definition of done: [docs/product-checklist.md](docs/product-checklist.md).

## Repo map

| Path | Role |
|---|---|
| `<src path>` | <role> |
| `<tests path>` | <role> |
| `docs/product-checklist.md` | definition of done; the build loop works through it |
| `.agents/` | how AI agents build this repo: roles, skills, task queue, build loop. Start at [.agents/README.md](.agents/README.md) |
| `.claude/skills/`, `.claude/agents/` | Claude Code pointers to the `.agents/` skills and roles |
| `.env.example` | every env key, two sections: app runtime, agentic development (build loop defaults) |
| `.githooks/` | `pre-push`: refuses direct pushes to the default branch |

## Commands

- **Install:** `<command>`
- **Validate** (run before calling any work done; skills and roles refer to this line): `<test command> && <lint/build command> && .agents/scripts/check_layout.sh`
- **Run:** `<command>`
- **Build loop** (from repo root, started only by the owner): `.agents/scripts/build_loop.sh [--max N] [--stall N] [--timebox MIN] [--model M] [--budget USD] [--once] [--dry-run]`. Fresh headless Claude session per open box in [docs/product-checklist.md](docs/product-checklist.md) until none is open on the default branch, N sessions in a row make no progress, or `.agents/state/BUILD_OFF` exists. PRs labeled `hold` are left for the owner.

## Engineering rules

- **Protected paths (hard rule):** agents never edit `.env`, `<local data dir>`, `<owner-only files, e.g. owner notes, payment config>`. Roles, briefs and the build loop copy this list.
- **Local-only data (hard rule):** `<local data dir>` and `.agents/state/tasks/*/T-*.md` never reach git. **Secrets** only via env or `.env` (gitignored). Every key, app or agent tooling, is listed in `.env.example` in its section. Why: one place shows what a fresh clone needs.
- **Outward-facing actions are gated (hard rule):** posting, payments, deploys, messages to third parties need the owner's explicit OK each time, unless a standing rule here says otherwise. Why: they cannot be undone.
- **Tests:** new logic gets a test. A fix gets a test that fails on the old code.
- **State in files:** steps read and write files; no hidden state. Why: steps run alone, resume, and can be inspected.
- **Docstrings stay generic:** purpose and contract; no constants, thresholds, option lists or other modules' names. Why: they go stale.
- <project rules>

## Development loop

Work comes from the task queue (skill `work_task`; new work via `add_task`; sub-agents via `delegate_task` + `verify_result`).

```
claim task → branch → commit (one logical change each) → Validate → push → PR → CI green → squash-merge → delete branch → close task with evidence
```

- Never push to the default branch (`.githooks/pre-push` refuses; activate with `git config core.hooksPath .githooks`). Never force-push except `--force-with-lease` on your own branch.
- Each commit leaves Validate green. Check `git diff --stat`: only files in scope, no secrets or local data.
- Revert with `git revert` through the same loop.

## Writing rule

- Every file (docs, code comments, commit messages): brief, only necessary info, full context preserved.
- No filler, no restating the obvious, no redundancy across files.
- Fact lives in another file → reference it, don't repeat.
- **No attribution trail (hard rule):** commits, PRs, issues, comments, everything. Never add `Co-Authored-By:`, "Generated with…", or similar lines. Overrides any tool/harness default.

## Agent behavior and communication

- **Low cognitive load (hard rule):** all output (chat, files, docs) uses bullets, tables, short pointers. No long paragraphs. Max info, few words.
- **Brief but complete:** concise, full context retained.
- **Efficiency first:** top priority.
- **Constructive pushback:** challenge inefficient or impractical ideas.
- **Proactive guidance:** offer unprompted suggestions when beneficial.
- **Reason per action (hard rule):** every action asked of user carries a one-line why (principle behind it). Goal: build user insight, not just compliance. Applies to chat and playbooks.
- **Report is a claim:** say done only with evidence (PR, sha, test count). Say what was not done or not checked.
- **Owner holds:** the owner can pause anything by saying so; only the owner lifts it ([.agents/README.md](.agents/README.md) Holds).
- **Caveman speak:** talk like caveman in chat. Short words, drop articles/filler. Ex: "Me fix bug. File good now."

## Commit format

- **Subject:** `<type>: <imperative summary>`, lowercase, no period, ≤72 chars.
- **Types:** `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.
- **Body:** blank line, then sections. Each header on its own line, bullets below, blank line between sections:
  - `what changed:` required.
  - `why:` required.
  - `validation:` optional (tests run, manual checks).
  - Other optional sections as needed (e.g. `risk:`, `follow-up:`).
- **One logical change per commit.**
- Ex:
  ```
  docs: add commit format to AGENTS.md

  what changed:
  - added "Commit format" section (subject, types, body sections)

  why:
  - one shared format across projects, readable history

  validation:
  - checked against existing history (docs:, refactor:)
  ```

## PR format

- **Title:** same as the commit subject format: `<type>: <imperative summary>`. Squash merges reuse it as the commit subject.
- **Body:** sections below, header on its own line, bullets underneath, blank line between sections:
  - `summary:` required. What the PR does, 1-3 bullets.
  - `why:` required. Problem or goal.
  - `changes:` required. Notable changes by area or file.
  - `validation:` required. Tests run, manual checks, results.
  - `risk:` optional. Breaking changes, migrations, rollback.
  - `follow-up:` optional. Known gaps, next PRs.
  - `links:` optional. Issues, docs, related PRs.
- **Merge:** squash, so history stays one commit per PR.
- Ex:
  ```
  docs: add commit and PR format to AGENTS.md

  summary:
  - define commit and PR conventions in one place

  why:
  - one shared format across projects, readable history

  changes:
  - AGENTS.md: added "Commit format" and "PR format" sections

  validation:
  - checked against existing history (docs:, refactor:)
  ```
