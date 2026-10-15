# Delegation

## Shared allowlist

Sub-agents see only their brief, so this block is pasted verbatim into every template below. It is the one allowed duplication; every other rule lives in one place.

```
RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, an Agent/Task/Skill call): stop and report instead.
```

## Brief template

Every template carries the Shared allowlist block verbatim. Each line should save the agent a search or a guess.

```
ROLE: <tier> implementer for task <id>. Do only this task.
GOAL: <one sentence>

CONTEXT (already gathered — don't re-explore):
- Own (may edit): <paths>
- Read only: <path:line-range>, …
- Contract: <paste the exact interface/types/signatures>
- Map (optional): <MAP line, only if the builder must locate code itself>
- Conventions: <naming, errors, test style — one line each>

STEPS (if mechanical): <numbered>

ACCEPTANCE:
- <verifiable bullet>
- Run `<command>` — must pass.

RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, an Agent/Task/Skill call): stop and report instead.
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

RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, an Agent/Task/Skill call): stop and report instead.
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
- Anything else (another file, another command, an Agent/Task/Skill call): stop and report instead.

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
MAP: <tool> — <allowed map tools/commands, named exactly> (fresh | possibly stale) | none
If MAP is not none: orient (report if any) → locate → trace through the map first, using only the named tools; read only files the map points to; confirm every fact in source with path:line (the map is never sole evidence); on a miss or contradiction grep, and flag "possibly stale"; inferred/ambiguous edges are hints; never build, install or update the map.
RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, an Agent/Task/Skill call): stop and report instead.
REPORT (≤40 lines): digest of facts, signatures only, path:line refs; facts only, quote the lines that matter.
```

## Analyst brief

```
ROLE: <tier> analyst for task <id>. Read-only. (Agent: subagent_type "general-purpose")
GOAL: <the question or audit angle>
INPUT: <paths / line ranges / facts already gathered>
MAP: <tool> — <allowed map tools/commands, named exactly> (fresh | possibly stale) | none
If MAP is not none: orient (report if any) → locate → trace through the map first, using only the named tools; read only files the map points to; confirm every fact in source with path:line (the map is never sole evidence); on a miss or contradiction grep, and flag "possibly stale"; inferred/ambiguous edges are hints; never build, install or update the map.
RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, an Agent/Task/Skill call): stop and report instead.
REPORT (≤30 lines): one finding per line, each with file:line evidence; fixes in one line at most; end with STATUS: done | blocked.
```

## Verifier brief

```
ROLE: haiku verifier. Run checks, change nothing. (subagent_type "general-purpose", model "haiku")
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
- Anything else (another file, another command, an Agent/Task/Skill call): stop and report instead.
SCOPE: run each command once; report failures, don't fix.
REPORT (≤15 lines per task): OUTSIDE-OWN: <paths> | none; then per task: <id> <command> pass|fail; for failures, the first error lines only.
```

## Reviewer brief

```
ROLE: sonnet reviewer, fresh context. Read-only. (subagent_type "general-purpose", model "sonnet")
GOAL: review the diffs for tasks <ids> against acceptance and contract.
INPUT: per task: <id> · `git diff -- <Own>` · Acceptance: <bullets>; Contract: <paste>
RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, an Agent/Task/Skill call): stop and report instead.
SCOPE: judge against acceptance and contract only.
REPORT (≤15 lines per task): findings, each tagged blocker | minor, with task id and file:line; or "no findings".
```

## Token rules

- **Inline, don't point.** Paste a 20-line interface. "Read the types folder" costs the agent 2,000 lines.
- **Line ranges, not whole files:** `src/api.ts:40-95`.
- **Scouts summarize, you decide.** Never pull large files into your context to "get a feel".
- **Gather once.** If two tasks need the same context, collect it once and inline it in both briefs.
- **Compact reports only.** The fixed format keeps sub-agent output from flooding your context.
- **Verify with digests, not files:** the verifier runs diffs and checks. Read specific hunks only where a digest or review points.
- **Cap your own output:** every command you run ends in `| tail -n 30` or uses `--stat` / `--name-only`. Never run a bare `git diff` without a path and a line limit.

## Slots (max 3)

Cap: see SKILL.md Guardrails. A builder frees its slot when it reports; verifiers and reviewers take freed slots. Start a task only when every dependency is verified and none of its Own files belongs to a live task.

```
[A][B][C]   wave 1: 1.1 haiku · 1.2 sonnet · 1.3 haiku
1.1 verified → slot A free → start 2.1 once the rule above holds
```
