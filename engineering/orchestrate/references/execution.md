# Execute and verify

## 4 · EXECUTE

- **Git check first.**
  - Not a git repo: ask whether to `git init` + make a baseline commit. This question is the one allowed commit prompt; a yes counts as the commit request for that baseline commit only. No AI attribution in its message (SKILL.md CLOSE). If declined: before each wave copy the owned files to the scratchpad and compare after with `diff -ru`; builders list changed files in their report.
  - Git repo: before wave 1, record `git status --porcelain` in the plan Log as the baseline.
- Repeat the PLAN budget check before each wave using the currently eligible providers (`--only <provider>` when one remains). Apply `references/providers.md` `## Routing and budget`.
- Split waves larger than the current slot cap before execution. Immediately before each launch, check provider eligibility per `references/providers.md` `## Routing and budget`. Follow `## Launching` for native or background CLI workers and `## Model map` for the model and effort. Follow `## No sub-agents` if delegation is unavailable.
- Fill and recycle slots per `references/delegation.md` `## Slots` and apply any cap change per `references/providers.md` `## Slots`.
- Every brief follows the matching template in `references/delegation.md` and carries the `## Shared allowlist` RULES block. Fast lane uses `## Fast-lane prompt`. Reference the plan's Contracts section; paste the contract only if it is under 20 lines.
- After launching, draft the next briefs into the plan file and wait for results per `references/providers.md` `## Launching`. Never predict or report a result before it lands.

## 5 · VERIFY

Verification runs in sub-agents. You judge their digests; you don't re-run their work.

When a wave's builders have all reported (or earlier, if a later task is waiting on one of them):
1. **Verifier** (light, `references/delegation.md` `## Verifier brief`): one per wave, covering every finished task, fast lane included. It checks for changes outside Own against the baseline and runs each task's checks.
2. **Reviewers:** batch all non-security standard and deep diffs for one fresh standard reviewer (`## Reviewer brief`), and all security diffs for one fresh deep reviewer (`## Security reviewer brief`). An early reviewer covers only finished tasks. When the remaining builders finish, send all outstanding diffs of each kind to one fresh reviewer of that kind. Scope each diff to its task's Own. Pair security reviewers per `references/providers.md` `## Security`, including task pauses and user-approved exceptions. Verifiers and reviewers count toward the slot cap.
3. **You:** compare builder report, verifier digest and review against acceptance + contract. Any change outside Own is a fail. Run a command yourself only when the reports disagree or a claim looks wrong: one command, through `2>&1 | tail -n 30`. Security tasks: read the full diff yourself (`git diff -- <Own>`).

**Read-only tasks** (audits, research, analysis: no diff, no checks): skip steps 1–2 and use the Analyst brief (security audits: `deep`). In step 3, spot-check every cited `file:line` or source yourself and drop claims that don't hold.

On failure, escalate. Retries use `references/delegation.md` `## Retry brief` (original brief + exact error + current `git diff -- <Own>`):
```
light    ✗ → retry once at light → standard
standard ✗ → retry once at standard → you pick: one deep attempt, or diagnose, re-scope or split yourself; log which and why
deep     ✗ → retry once at deep → you diagnose, re-scope or split → re-delegate
```
If a cross-provider task fails its retry, try it on the host provider at the same tier before climbing, only if that provider is eligible for the role. Security builds and reviews always follow `references/providers.md` `## Security`. Rate-limit and auth failures follow `## Launching` in that reference.

If the re-delegated attempt after your diagnosis also fails, set plan Status `Paused`, report to the user, and stop launching.

You may make one fix of ≤5 lines per task, only for a defect found in VERIFY. Any Write, Edit, sed or heredoc you run on a non-bookkeeping file counts as that fix; log it as `VERIFY fix <task> (<n> lines)`. A second fix, or more than 5 lines, goes back to a builder. Log every retry and escalation in the plan file.

After the final wave, a verifier runs the full **Verify with** suite. Map each failure to the task that owns the failing file and re-enter that task's escalation ladder.
