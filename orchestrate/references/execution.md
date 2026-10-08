# Execute and verify

## 4 · EXECUTE

- **Git check first.**
  - Not a git repo: ask whether to `git init` + make a baseline commit. This question is the one allowed commit prompt; a yes counts as the commit request for that baseline commit only. If declined: before each wave copy the owned files to the scratchpad and compare after with `diff -ru`; builders list changed files in their report.
  - Git repo: before wave 1, record `git status --porcelain` in the plan Log as the baseline.
- Launch a wave as **up to 3 Agent (Task) calls in one message** (they run in parallel).
- Set `model: "haiku"` or `model: "sonnet"` explicitly on every call. Never let a sub-agent inherit your model.
- Set `subagent_type`: `Explore` for scouts only (it locates code; it doesn't review or edit). Builders, analysts, reviewers and check-runners use `general-purpose`; tell the non-builders not to edit.
- Fill and recycle slots per `references/delegation.md` `## Slots`.
- Every brief follows the matching template in `references/delegation.md` and carries the `## Shared allowlist` RULES block. Fast lane uses `## Fast-lane prompt`. Sub-agents know nothing about this conversation; put everything they need in the brief.
- After launching, draft the next briefs into the plan file, then end your turn. Results arrive as notifications; never predict or report a result before it lands.

## 5 · VERIFY

For each finished task:
1. **Check-runner** (haiku, see "Check-runner brief"): only when the task has 2+ check commands and you are not in fast lane. Runs the task's checks, returns a failure digest (≤15 lines). Otherwise skip to step 3.
2. **Reviewer** (sonnet, fresh context, read-only, see "Reviewer brief"): only for sonnet-tier and security-sensitive tasks. Returns findings against acceptance + contract.
3. **You:** read the builder's compact report. Run `git diff --stat -- <Own>` and `git status --porcelain`; any change outside Own (compared with the baseline) is a fail. No git: `diff -ru` against the scratchpad copy. Judge pass/fail against acceptance + contract. Re-run ONE key check yourself, piped through `2>&1 | tail -n 30`. No check commands: verify by reading its diff. Never trust "pass" blindly. Read hunks only where the digest or review points, except security-sensitive tasks: read the full diff yourself.

**Read-only tasks** (audits, research, analysis: no diff, no checks): skip steps 1–2 and use the Analyst brief. In step 3, spot-check every cited `file:line` or source yourself and drop claims that don't hold.

On failure, escalate. Retries use `references/delegation.md` `## Retry brief` (original brief + exact error + current `git diff -- <Own>`):
```
haiku  ✗ → retry once on haiku with a Retry brief → sonnet
sonnet ✗ → retry once with a Retry brief → you diagnose, re-scope or split → re-delegate
```
If the re-delegated attempt after your diagnosis also fails, set plan Status `Paused`, report to the user, and stop launching.

You may make one fix of ≤5 lines per task, only for a defect found in VERIFY. Anything more goes back to a builder. Log every retry and escalation in the plan file.

After the final wave, a haiku check-runner runs the full **Verify with** suite. Map each failure to the task that owns the failing file and re-enter that task's escalation ladder.
