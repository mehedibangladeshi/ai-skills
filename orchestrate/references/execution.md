# Execute and verify

## 4 · EXECUTE

- **Git check first.**
  - Not a git repo: ask whether to `git init` + make a baseline commit. This question is the one allowed commit prompt; a yes counts as the commit request for that baseline commit only. No AI attribution in its message (SKILL.md CLOSE). If declined: before each wave copy the owned files to the scratchpad and compare after with `diff -ru`; builders list changed files in their report.
  - Git repo: before wave 1, record `git status --porcelain` in the plan Log as the baseline.
- Launch a wave as **up to 3 Agent (Task) calls in one message** (they run in parallel).
- Set `model: "haiku"` or `model: "sonnet"` explicitly on every call, including custom `subagent_type`s (project agents). Never let a sub-agent inherit your model.
- Set `subagent_type`: `Explore` for scouts only (it locates code; it doesn't review or edit). Builders, analysts, reviewers and verifiers use `general-purpose`; tell the non-builders not to edit.
- Fill and recycle slots per `references/delegation.md` `## Slots`.
- Every brief follows the matching template in `references/delegation.md` and carries the `## Shared allowlist` RULES block. Fast lane uses `## Fast-lane prompt`. Sub-agents know nothing about this conversation; put everything they need in the brief.
- After launching, draft the next briefs into the plan file, then end your turn. Results arrive as notifications; never predict or report a result before it lands.

## 5 · VERIFY

Verification runs in sub-agents. You judge their digests; you don't re-run their work.

When a wave's builders have all reported (or earlier, if a later task is waiting on one of them):
1. **Verifier** (haiku, `references/delegation.md` `## Verifier brief`): one per wave, covering every finished task, fast lane included. It checks for changes outside Own against the baseline and runs each task's checks.
2. **Reviewer** (sonnet, `## Reviewer brief`): sonnet-tier and security-sensitive tasks only. One reviewer covers all such tasks in the wave, with each task's diff scoped to its Own. It shares the wave with the verifier (counts toward the slot cap).
3. **You:** compare builder report, verifier digest and review against acceptance + contract. Any change outside Own is a fail. Run a command yourself only when the reports disagree or a claim looks wrong: one command, through `2>&1 | tail -n 30`. Security-sensitive tasks: read the full diff yourself (`git diff -- <Own>`).

**Read-only tasks** (audits, research, analysis: no diff, no checks): skip steps 1–2 and use the Analyst brief. In step 3, spot-check every cited `file:line` or source yourself and drop claims that don't hold.

On failure, escalate. Retries use `references/delegation.md` `## Retry brief` (original brief + exact error + current `git diff -- <Own>`):
```
haiku  ✗ → retry once on haiku with a Retry brief → sonnet
sonnet ✗ → retry once with a Retry brief → you diagnose, re-scope or split → re-delegate
```
If the re-delegated attempt after your diagnosis also fails, set plan Status `Paused`, report to the user, and stop launching.

You may make one fix of ≤5 lines per task, only for a defect found in VERIFY. Any Write, Edit, sed or heredoc you run on a non-bookkeeping file counts as that fix; log it as `VERIFY fix <task> (<n> lines)`. A second fix, or more than 5 lines, goes back to a builder. Log every retry and escalation in the plan file.

After the final wave, a verifier runs the full **Verify with** suite. Map each failure to the task that owns the failing file and re-enter that task's escalation ladder.
