# Delegation

## Shared allowlist

Sub-agents see only their brief, so this block is pasted verbatim into every template below. It is the one allowed duplication; every other rule lives in one place.

```
RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, a sub-agent spawn or skill call): stop and report instead.
```

## Brief template

Every template carries the Shared allowlist block verbatim. Each line should save the agent a search or a guess.

```
ROLE: <tier> implementer for task <id>. Launch per providers.md ## Launching. Do only this task.
GOAL: <one sentence>

CONTEXT (already gathered — don't re-explore):
- Own (may edit): <paths>
- Read only: <path:line-range>, …
- Contract: <paste if <20 lines, else "see plan file ## Contracts"; path>
- Map (optional): <MAP line, only if the builder must locate code itself>
- Conventions: <naming, errors, test style — one line each>

STEPS (if mechanical): <numbered>

ACCEPTANCE:
- <verifiable bullet>
- Run `<command>` — must pass.

RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, a sub-agent spawn or skill call): stop and report instead.
SCOPE: stay on this task; contract unchanged; no unrelated refactors or new dependencies.
If blocked or the contract looks wrong, STOP and report. Don't improvise.

REPORT (≤15 lines, exactly):
STATUS: done | blocked | partial
CHANGED: <file — one-line summary>, …
CHECKS: <command → result>
NOTES: <deviations, assumptions, must-knows>
```

## Filled example (builder)

```
ROLE: light implementer for task 1.2. Launch per providers.md ## Launching. Do only this task.
GOAL: add a `--json` flag to scripts/report.sh that prints the summary as JSON.

CONTEXT (already gathered — don't re-explore):
- Own (may edit): scripts/report.sh
- Read only: scripts/lib.sh:10-40
- Contract: `report.sh [--json]`; JSON keys: total, passed, failed (integers)
- Conventions: bash with `set -u`; errors to stderr

ACCEPTANCE:
- `scripts/report.sh --json | jq .total` prints an integer
- Run `scripts/report.sh --self-test` — must pass.

RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, a sub-agent spawn or skill call): stop and report instead.
SCOPE: stay on this task; contract unchanged; no unrelated refactors or new dependencies.
If blocked or the contract looks wrong, STOP and report. Don't improvise.

REPORT (≤15 lines, exactly): STATUS / CHANGED / CHECKS / NOTES
```

## Retry brief

A retry = the original brief + a `FAILED ATTEMPT:` block. Start from the current state of Own, not a clean slate.

```
<original brief, unchanged>

FAILED ATTEMPT:
Error output:
<exact error output>
Current diff:
<output of `git diff -- <Own>`>
Start from the current state of Own: fix or undo the failed attempt's edits; don't stack on them.
```

## Fast-lane prompt

For trivial tasks. Plain task, Own, one check.

```
<task in 1–3 plain lines>
Own: <paths>
Check: <command>

RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, a sub-agent spawn or skill call): stop and report instead.

REPORT (≤15 lines, exactly):
STATUS: done | blocked | partial
CHANGED: <file — one-line summary>, …
CHECKS: <command → result>
NOTES: <deviations, assumptions, must-knows>
```

## Scout brief

```
ROLE: <tier> scout (light, standard if cross-module). Launch per providers.md ## Launching. Read-only.
GOAL: <the question>
INPUT: <paths / globs / terms to look at>
MAP: <tool> — <allowed map tools/commands, named exactly> (fresh | possibly stale) | none
If MAP is not none: orient (report if any) → locate → trace through the map first, using only the named tools; read only files the map points to; confirm every fact in source with path:line (the map is never sole evidence); on a miss or contradiction grep, and flag "possibly stale"; inferred/ambiguous edges are hints; never build, install or update the map.
RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, a sub-agent spawn or skill call): stop and report instead.
REPORT (≤40 lines): digest of facts, signatures only, path:line refs; facts only, quote the lines that matter.
```

## Analyst brief

```
ROLE: <tier> analyst for task <id>. Launch per providers.md ## Launching. Read-only.
GOAL: <the question or audit angle>
INPUT: <paths / line ranges / facts already gathered>
MAP: <tool> — <allowed map tools/commands, named exactly> (fresh | possibly stale) | none
If MAP is not none: orient (report if any) → locate → trace through the map first, using only the named tools; read only files the map points to; confirm every fact in source with path:line (the map is never sole evidence); on a miss or contradiction grep, and flag "possibly stale"; inferred/ambiguous edges are hints; never build, install or update the map.
RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, a sub-agent spawn or skill call): stop and report instead.
REPORT (≤30 lines): one finding per line, each with file:line evidence; fixes in one line at most; end with STATUS: done | blocked.
```

## Verifier brief

```
ROLE: light verifier. Launch per providers.md ## Launching. Run checks, change nothing.
GOAL: verify wave <n>: tasks <ids>.
INPUT:
- Baseline `git status --porcelain`: <paste from plan Log>
- Per task: <id> · Own: <paths> · Checks: <commands>
STEPS:
1. Run `git status --porcelain` and `git diff --stat`; list every changed or new path not in any task's Own and not in the baseline. No git: `diff -ru <scratchpad copy> <dir>`.
2. Run each task's checks once, each through `2>&1 | tail -n 30`.
RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, a sub-agent spawn or skill call): stop and report instead.
SCOPE: run each command once; report failures, don't fix.
REPORT (≤15 lines per task): OUTSIDE-OWN: <paths> | none; then per task: <id> <command> pass|fail; for failures, the first error lines only.
```

## Reviewer brief

```
ROLE: standard reviewer, fresh context. Launch per providers.md ## Launching. Read-only.
GOAL: review the diffs for tasks <ids> against acceptance and contract.
INPUT: per task: <id> · `git diff -- <Own>` · Acceptance: <bullets>; Contract: <paste if <20 lines, else "see plan file ## Contracts"; path>
RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, a sub-agent spawn or skill call): stop and report instead.
SCOPE: judge against acceptance and contract only.
REPORT (≤15 lines per task): findings, each tagged blocker | minor, with task id and file:line; or "no findings".
```

## Security reviewer brief

```
ROLE: deep security reviewer, fresh context. Use the other provider (same provider with --single-provider) per providers.md ## Security. Launch per providers.md ## Launching. Read-only.
GOAL: hunt vulnerabilities in the diffs for tasks <ids>.
INPUT: per task: <id> · `git diff -- <Own>` · Security surface touched: <surface> · Acceptance: <bullets>
FOCUS: injection, authz bypass, secret exposure, unsafe path/file handling, crypto misuse, unsafe defaults, dependency risk.
RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, a sub-agent spawn or skill call): stop and report instead.
SCOPE: vulnerabilities in the diff only; contract unchanged.
REPORT (≤15 lines per task): findings, each tagged blocker | minor, with task id, file:line and a one-line fix; or "no findings".
```

## Token rules

- **Contracts:** paste contracts shorter than 20 lines. For longer contracts, give the plan path and point to `## Contracts`.
- **Line ranges, not whole files:** `src/api.ts:40-95`.
- **Scouts summarize, you decide.** Never pull large files into your context to "get a feel".
- **Gather once.** If two tasks need the same context, collect it once and inline it in both briefs.
- **Compact reports only.** The fixed format keeps sub-agent output from flooding your context.
- **Batch reviews.** One reviewer of each kind covers all finished diffs of that kind; a later batch only for diffs an early review missed (execution.md VERIFY step 2). A standard and a security reviewer may share a wave.
- **PLAN handoff:** send only the lock (drafted if zero questions were asked), scout digests, and `planning.md` `## Steps`. The host plans the fast lane.
- **Verify with digests, not files:** the verifier runs diffs and checks. Read specific hunks only where a digest or review points.
- **Cap your own output:** every command you run ends in `| tail -n 30` or uses `--stat` / `--name-only`. Never run a bare `git diff` without a path and a line limit.

## Slots

Use the run's slot cap (3 by default, up to 5 with opt-in) across providers and roles. See `providers.md` `## Slots`. A builder frees its slot when it reports; verifiers and reviewers take freed slots. Start a task only when every dependency is verified and none of its Own files belongs to a live task.

```
[A][B][C]   wave 1: 1.1 light · 1.2 deep · 1.3 standard
1.1 verified → slot A free → start 2.1 once the rule above holds
```
