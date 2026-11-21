# Skill: work_task

**Description:** Claim a task from the queue, do it on a branch, open the PR, close it with evidence.

## Procedure
1. **Pick:** in `.agents/state/tasks/planned/`, the task whose `depends:` are all in `done/`, lowest `priority`, then lowest id. Skip tasks with a `## Holds` line. Or take the id the owner or lead named.
2. **Claim:** move the file to `active/`, set `status: active`, `owner:`, `updated:`, and add a `## Log` line. Why: other agents see it is taken.
3. **Branch:** `git fetch && git switch -c task/T-NNN origin/<default>`. If agents work in parallel, use `.agents/scripts/worktree.sh T-NNN` instead (links the ignored setup in). Set `branch:` in the task.
4. **Build:** only the task's scope; tests for new logic; docs that describe the change. One logical change per commit ([AGENTS.md](../../../AGENTS.md) commit format, no trailers).
5. **Validate:** the AGENTS.md Validate line; `git diff --stat origin/<default>`: only in-scope files, no secrets, local data or setup files.
6. **Builder stops here** and reports (see `agents/builder`). The lead continues.
7. **PR (lead):** `git push -u origin task/T-NNN`, then `gh pr create` with the AGENTS.md PR format; `gh pr checks --watch`; on green, `gh pr merge --squash --delete-branch`; `git switch <default> && git pull --ff-only`; remove the worktree if one was made (`.agents/scripts/worktree.sh --remove T-NNN`).
8. **Close:** move the task to `done/`, `status: done`, and a `## Log` line with the PR number, merged sha and test count. If it can't be finished, log why and move it back to `planned/` (or `dropped/` with the reason).

**Evidence:** the task's last log line names the PR, sha and test count.
