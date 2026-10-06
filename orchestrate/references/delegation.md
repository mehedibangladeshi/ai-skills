# Delegation

## Brief template

Every builder Agent call uses this shape. Each line should save the agent a search or a guess. Every brief's DO NOT line, of any kind, also bans git write commands (add, commit, push, tag, reset, stash), deletes outside Own, and publishing.

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

DO NOT: edit files outside "Own"; refactor unrelated code; add dependencies; change the contract; no git write commands; no deletes outside Own; no publishing.
If blocked or the contract looks wrong, STOP and report. Don't improvise.

REPORT (≤15 lines, exactly):
STATUS: done | blocked | partial
CHANGED: <file — one-line summary>, …
CHECKS: <command → result>
NOTES: <deviations, assumptions, must-knows>
```

## Filled example (builder)

```
ROLE: haiku implementer for task 1.2. Do only this task.
GOAL: add a `--json` flag to scripts/report.sh that prints the summary as JSON.

CONTEXT (already gathered — don't re-explore):
- Own (may edit): scripts/report.sh
- Read only: scripts/lib.sh:10-40
- Contract: `report.sh [--json]`; JSON keys: total, passed, failed (integers)
- Conventions: bash with `set -u`; errors to stderr

ACCEPTANCE:
- `scripts/report.sh --json | jq .total` prints an integer
- Run `scripts/report.sh --self-test` — must pass.

DO NOT: edit files outside "Own"; refactor unrelated code; add dependencies; change the contract; no git write commands; no deletes outside Own; no publishing.
If blocked or the contract looks wrong, STOP and report. Don't improvise.

REPORT (≤15 lines, exactly): STATUS / CHANGED / CHECKS / NOTES
```

## Scout brief

```
ROLE: haiku scout. Read-only. (Agent: subagent_type "Explore", model "haiku")
GOAL: <the question>
INPUT: <paths / globs / terms to look at>
DO NOT: edit anything; propose designs; paste whole files.
REPORT (≤40 lines): digest of facts, signatures only, path:line refs.
```

## Analyst brief

```
ROLE: <tier> analyst for task <id>. Read-only. (Agent: subagent_type "general-purpose", told not to edit)
GOAL: <the question or audit angle>
INPUT: <paths / line ranges / facts already gathered>
DO NOT: edit files; run git write commands; propose rewrites longer than one line.
REPORT (≤30 lines): one finding per line, each with file:line evidence; end with STATUS: done | blocked.
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
ROLE: sonnet reviewer, fresh context. Read-only. (subagent_type "general-purpose", told not to edit)
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

Cap: see SKILL.md Guardrails. A builder frees its slot when it reports; check-runners and reviewers take freed slots.

```
[A][B][C]   wave 1: 1.1 haiku · 1.2 sonnet · 1.3 haiku
1.1 verified → slot A free → start 2.1 if every dependency of 2.1 is verified
```
