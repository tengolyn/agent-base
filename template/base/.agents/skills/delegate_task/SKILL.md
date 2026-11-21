# Skill: delegate_task

**Description:** Write the brief a lead sends to a sub-agent (builder or reviewer). Use before every delegation; pair with `verify_result`.

## Procedure
1. **Check it is delegable:** bounded, verifiable, files disjoint from other running work, no owner-only action, no hold. Why: overlapping files make merge conflicts and lost work.
2. **Brief.** The sub-agent starts cold, so fill every part:
   - **Task:** id, goal, done-when (paste them from the task file).
   - **Files:** allowed paths; forbidden paths (always the AGENTS.md protected paths, and other agents' files).
   - **Where:** `.agents/scripts/worktree.sh T-NNN` (prints the path); work only there.
   - **Limits:** no push, PR, merge or task close; no outward-facing actions or real external calls unless stated; any active hold, copied word for word.
   - **Stop rule:** when blocked, or after two failed attempts at the same thing, stop and report. Never force.
   - **Report:** under 150 words: what changed, tests and result, branch and sha, what was not done or not checked.
3. **Spawn** with the matching role (`.claude/agents/builder.md` or `reviewer.md`). Log a line in the task. Work on something else meanwhile.

**Evidence:** the brief has all six parts; the task log names the sub-agent.
