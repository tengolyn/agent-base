# Skill: create_agent

**Description:** Add a new role: a standing set of duties, reads, writes and limits.

## Procedure
1. **Confirm it is a role:** recurring duties that no current role covers. Otherwise extend an existing role or write a skill.
2. **Write** `.agents/agents/<snake_name>/AGENT.md`: `# Agent: <name>`, `**Role:**` (one line), then bullets for Skills, Reads, Writes and Boundary (what it never does). Add Output when its result has a fixed form.
3. **Pointer** (only for roles Claude Code spawns as sub-agents): `.claude/agents/<name>.md` with frontmatter `name`, `description`, and `tools` when the role is limited (e.g. read-only), and a body that links to the role file. Roles run by the app itself (e.g. an AI step inside the product) get no pointer.
4. **List it** in `.agents/README.md`.

**Evidence:** the files exist, the README lists the role, and `.agents/scripts/check_layout.sh` passes.
