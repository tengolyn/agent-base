# Product checklist: what the finished <project> is

Definition of done. The build loop (`.agents/scripts/build_loop.sh`) works through it top to bottom and stops when no box is open on the default branch.

Rules:
- Tick a box (`- [x]`) only in the PR that makes it true, and add ` (#PR)` at the end of the line.
- Every box must be checkable by a test or a command; the PR's validation section shows that check.
- Changing the meaning of an item is the owner's call. Agents may split one item into smaller ones, but they may not delete or weaken it.
- One box ≈ one PR. Why: the loop finishes one box per session.

## 0. Foundation
- [ ] <repo layout, CI runs Validate>
- [ ] <README quickstart: install, run, first result>

## 1. <area>
- [ ] <checkable item>
