# Skill: create_skill

**Description:** Add a new skill: a repeatable procedure with checkable evidence.

## Procedure
1. **Confirm it is a skill:** a procedure done more than once, with a clear end. One-off work is a task; a standing role is an agent.
2. **Keep it narrow:** if the steps branch a lot, split it into several skills.
3. **Write** `.agents/skills/<snake_name>/SKILL.md`: `# Skill: <name>`, `**Description:**` (one line), `## Procedure` (numbered, dense, a why on non-obvious steps), `**Evidence:**` (how anyone checks it was done). Put long examples or schemas in `reference/` next to it.
4. **Pointer:** `.claude/skills/<snake_name>/SKILL.md` with frontmatter `name` and `description` (same as the skill), and a body that links to the skill file. Why: Claude Code discovers skills there.
5. **List it** in the skills row of `.agents/README.md` and in the roles that use it.

**Evidence:** both files exist, the README lists the skill, and `.agents/scripts/check_layout.sh` passes.
