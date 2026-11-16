# Rigup

My personal agentic development environment: one fixed setup to drop into any project.

## Use
```bash
git clone --depth 1 git@github.com:tengolyn/agent-base.git /tmp/rigup && rsync -a --ignore-existing --exclude=/.git --exclude=/README.md --exclude=/.gitignore /tmp/rigup/ ./
```
Copies everything except `.git`, `README.md`, `.gitignore`. `--ignore-existing` never overwrites existing files. Then fill in the project purpose in `AGENTS.md`.

## Contents
- `AGENTS.md`: router and entry point (tool-agnostic).
- `CLAUDE.md`: points Claude at `AGENTS.md`.
- `.agents/skills/`, `.agents/agents/`: shared skills and agents.
- `.claude/skills/`: thin Claude wrappers around the shared skills.