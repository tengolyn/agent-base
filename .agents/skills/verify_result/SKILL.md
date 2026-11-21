# Skill: verify_result

**Description:** The lead's checks on a sub-agent's work before the PR merges and the task closes. A report is a claim until these pass.

## Procedure
1. **Read the commits, not the report:** `git log --oneline origin/<default>..task/T-NNN`, then `git diff --stat origin/<default>...task/T-NNN`.
2. **Scope:** every changed file is inside the brief's allowed paths, and none is forbidden. Why: scope creep is the usual silent failure.
3. **Validate:** run the AGENTS.md Validate line in the task worktree yourself.
4. **New tests bite:** for a fix or feature, run the new tests against the old code (`git stash` the source change, or check out `origin/<default>` with only the new test files); they must fail. Why: a test that passes on old code proves nothing.
5. **Rules:** docs updated; no secrets or local data; no attribution trailers (`git log --format=%B`); docstrings generic.
6. **Pass:** continue with `work_task` step 7 (PR, CI, merge, close with evidence).
7. **Fail:** don't merge. Send the gap back (file, check number, expected vs found) and re-verify the new commit from step 1.

**Evidence:** the task log names the sha, the test count and the checks that passed.
