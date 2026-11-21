# Skill: add_task

**Description:** Turn a request, finding or follow-up into a task file in the queue.

## Procedure
1. **Check for duplicates:** search the titles in all four `.agents/state/tasks/` folders. If a task already covers it, add a log line there instead.
2. **Id:** the highest `T-NNN` across all folders, plus one.
3. **Write the file:** copy `.agents/templates/task.md` to `.agents/state/tasks/planned/T-NNN.md` and fill every field: an imperative title, a goal with the why, checkable done-when items, scope (allowed and not), `depends:`, `kind`, `priority`.
4. **Split if needed:** a task bigger than one PR becomes several tasks chained with `depends:`. Why: one task, one branch, one PR.
5. **Log** the source in `## Log` (owner request with the date, or the task it came from).

**Evidence:** the file exists in `planned/`, its id is unique, and every field is filled.
