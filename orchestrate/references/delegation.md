# Delegation

## Brief template

Every builder Agent call uses this shape. Each line should save the agent a search or a guess.

```
ROLE: <tier> implementer for task <id>. Do only this task.
GOAL: <one sentence>

CONTEXT (already gathered — don't re-explore):
- Own (may edit): <paths>
- Read only: <path:line-range>, …
- Contract: <paste the exact interface/types/signatures>
- Conventions: <naming, errors, test style — one line each>

STEPS (if mechanical): <numbered>

ACCEPTANCE:
- <verifiable bullet>
- Run `<command>` — must pass.

DO NOT: edit files outside "Own"; refactor unrelated code; add dependencies; change the contract.
If blocked or the contract looks wrong, STOP and report. Don't improvise.

REPORT (≤15 lines, exactly):
STATUS: done | blocked | partial
CHANGED: <file — one-line summary>, …
CHECKS: <command → result>
NOTES: <deviations, assumptions, must-knows>
```

## Scout brief

```
ROLE: haiku scout. Read-only. (Agent: subagent_type "Explore", model "haiku")
GOAL: <the question>
INPUT: <paths / globs / terms to look at>
DO NOT: edit anything; propose designs; paste whole files.
REPORT (≤40 lines): digest of facts, signatures only, path:line refs.
```

## Check-runner brief

```
ROLE: haiku check-runner. Run checks, change nothing.
GOAL: report whether the checks pass for task <id>.
INPUT: commands: <tests / lint / typecheck for the touched area>
DO NOT: edit files; fix failures; re-run more than once.
REPORT (≤15 lines): per command pass|fail; for failures, the first error lines only.
```

## Reviewer brief

```
ROLE: sonnet reviewer, fresh context. Read-only. (subagent_type "Explore", or general-purpose told not to edit)
GOAL: review the diff for task <id> against acceptance and contract.
INPUT: `git diff` (or changed files); Acceptance: <bullets>; Contract: <paste>
DO NOT: edit files; rewrite code; comment on style outside the contract.
REPORT (≤15 lines): findings, each tagged blocker | minor, with file:line; or "no findings".
```

## Token rules

- **Inline, don't point.** Paste a 20-line interface. "Read the types folder" costs the agent 2,000 lines.
- **Line ranges, not whole files:** `src/api.ts:40-95`.
- **Scouts summarize, you decide.** Never pull large files into your context to "get a feel".
- **Gather once.** If two tasks need the same context, collect it once and inline it in both briefs.
- **Compact reports only.** The fixed format keeps sub-agent output from flooding your context.
- **Verify with diffs, not files:** `git diff --stat` (or `diff -ru` without git), then the specific hunks.

## Slots (max 3)

One cap covers all live agents: builders, scouts, check-runners, reviewers.

```
[A][B][C]   wave 1: 1.1 haiku · 1.2 sonnet · 1.3 haiku
1.1 verified → slot A free → start 2.1 if every dependency of 2.1 is verified
```
