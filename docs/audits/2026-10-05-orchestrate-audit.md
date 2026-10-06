# Audit: `orchestrate` skill
Date: 2026-10-05 · Scope: `orchestrate/SKILL.md` + `references/*.md` · Status: report only, no fixes applied
Angles: internal consistency, guardrails, references vs SKILL.md, harness fit, tool usage, real-run evidence, context/token efficiency, trigger/command words, ease for agents/models.
Method: 3 sonnet auditors (read-only), then orchestrator spot-checked every citation, deduped, and ranked them.

## High

| ID | Where | Gap | Failure it allows | Fix |
|---|---|---|---|---|
| G01 | SKILL.md:103-105, delegation.md:56 | No path for read-only tasks (audit, research): the reviewer needs a diff, the check-runner needs checks, step 3 uses `git diff --stat`, and there is no analyst brief | VERIFY can't be followed literally; the orchestrator improvises or skips verification | Add an analyst brief + a no-diff verify path: spot-check cited file:line claims |
| G02 | delegation.md:23, SKILL.md:125 | Builder/reviewer briefs don't ban git writes, deletes or publishing; the no-commit rule binds only the orchestrator | A builder commits, pushes or deletes, which is irreversible | Add "no git add/commit/push/tag, no rm outside Own, no publishing" to every brief's DO NOT |
| G03 | SKILL.md:126 vs :113, :46 | "Never implement" lives only in Guardrails and clashes with "fix ≤5 lines yourself" and "settle the design yourself"; ≤5 lines can repeat | The orchestrator implements piecemeal (R1: did the whole job) | Put it at the top of the skill; ≤5-line fixes are the sole named exception, max 1 per task |
| G04 | SKILL.md:86-89 | No stop/pause/resume words; "reject" behaviour undefined | User says "stop" mid-wave → live agents and plan state undefined; no resume across sessions | Define stop (no new launches, Status Paused), resume (re-read newest plan), reject (Status Rejected, change nothing) |

## Medium

| ID | Where | Gap | Failure it allows | Fix |
|---|---|---|---|---|
| G05 | SKILL.md:29 | Fast-lane line packs 7 rules; "confirm the goal in one line" conflicts with "one wait: the mini preview" | Literal followers drop rules or ask twice | Split into a checklist; the mini preview is the only confirmation |
| G06 | SKILL.md:97 vs :29 | "Every brief follows the matching template" vs fast lane's plain prompts | Cannot satisfy both | Add "except fast lane" to line 97 |
| G07 | SKILL.md:95 | `subagent_type` for builders not stated | Builder launched as Explore can't edit; reviewer launched as general-purpose can | Builders: general-purpose; scouts: Explore |
| G08 | SKILL.md:26, delegation.md:56 | Explore used for reviewers and claim-checking, but Explore only locates code and doesn't review | Shallow or empty reviews | Reviewers/auditors: general-purpose told read-only; Explore for locating only |
| G09 | SKILL.md:94 | No rule to end the turn after launching and act only on completion notifications | Orchestrator predicts results or moves to VERIFY early | Add: "after launch, end turn; never predict results" |
| G10 | SKILL.md:125 vs :128 | Commit/release rule and "publishing" confirm overlap; is a goal of "release X" a request? "publishing" undefined | Irreversible publish on plan approval alone | One rule: commit/push/tag/release/publish need a fresh explicit yes at that moment |
| G11 | SKILL.md:120 | Suggested commits don't say which convention; harness adds Co-Authored-By, user's /git-commit forbids it | Commit carries a forbidden trailer | "Commits go through /git-commit" |
| G12 | SKILL.md:81, :36 | Preview lists "integration" as orchestrator-only with no owner or tier | Glue code written by the orchestrator or dropped | Drop "integration" or make it a task row |
| G13 | SKILL.md:58, :66 | Status has no Verifying/Paused; Log doesn't record agent IDs or per-task state | After compaction: can't tell EXECUTE from VERIFY; orphaned or duplicate agents | Add Verifying/Paused; log launch/finish with agent IDs |
| G14 | SKILL.md:30, :70 | Full lane always waits twice (lock, then preview), even when grilling resolved everything | Extra round-trip (this audit run) | Merge lock into the preview when no open questions remain |
| G15 | SKILL.md:103, :105 | Check-runner runs checks that the orchestrator re-runs anyway | Extra agent + round-trip per task | Skip the check-runner when the task has ≤1 check command |
| G16 | SKILL.md:89, :30 | Approval words are only examples; the lock confirm has none | "ok, but…" read as approval, or "yes" stalls | One list: approve/go/yes/lgtm = start; anything else = edit |
| G17 | delegation.md:72-78, SKILL.md:96 | Slots free only when a task is "verified", but verify agents need slots too | Deadlock or a 4th live agent | A finished builder releases its slot on report |
| G18 | SKILL.md:46-50 | Precedence of the security override vs "when unsure pick lower" unstated | Security work under-tiered | "Overrides beat the pick-lower rule" |
| G19 | SKILL.md:36, :51, :96 | Jargon (contract, wave, slot, lock, fast lane) used before or without definition | Weaker models invent meanings | 5-line glossary at top |

## Low

| ID | Where | Gap | Failure it allows | Fix |
|---|---|---|---|---|
| G20 | SKILL.md:93 | `git init` + baseline commit vs the no-commit rule; declined path vs `git diff --stat` in step 3 | Ambiguous permission; wrong diff command | Mark the git init question as the exception; step 3 uses `diff -ru` when no git |
| G21 | grill-with-docs.md:9, SKILL.md:24 | "One question at a time" vs multi-question AskUserQuestion; free-text "Other" handling unstated | Batched grilling; scope added via Other gets ignored | One question per call; treat Other text as scope input (delta preview) |
| G22 | SKILL.md:94, :127, delegation.md:74 | 3-agent cap stated 3 times | Wasted tokens each load | State it once in Guardrails |
| G23 | SKILL.md:34 | "Think hard" is redundant | Extra reasoning tokens | Delete it |
| G24 | SKILL.md:3-5 | Long, arrow-heavy description; no example invocation | Weaker discoverability | Shorten; add an example to argument-hint |
| G25 | delegation.md:7-31 | No filled brief example | "Contract" mis-filled | Add one 10-line filled example |

## Rejected
- "Drop the todo-tool clause / plan file optional": the plan file is already mandatory in fast lane (SKILL.md:29); the clause is harmless where a todo tool exists.
- "Force reading references first": grill-with-docs is already explicit (SKILL.md:24); fast lane skips it on purpose.
- "Symlinked skill can change mid-run": speculative, no failure observed.
