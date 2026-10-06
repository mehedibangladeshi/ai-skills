# Orchestrate skill: blind static review (Layer B)

- Date: 2026-10-06
- Scope: `orchestrate/SKILL.md`, `orchestrate/references/{ADR-FORMAT,CONTEXT-FORMAT,delegation,grill-with-docs}.md`
- Lenses: `writing-for-agents` (pointers, hierarchy, completion criteria, leading words, negation, pruning) and the `superpowers:writing-skills` checklist
- Blind: `docs/audits/` and `docs/plans/` were not read. Findings come only from the skill text.
- Severity: **High** = can corrupt work, break the gate, or loop without bound · **Medium** = likely wrong path or wasted run · **Low** = load, duplication, or style

## High

### H1. Slot recycling breaks single-file ownership
- **Where:** `SKILL.md:110`, `references/delegation.md:110` (rule set at `SKILL.md:58`)
- **Gap:** One owner per file is only guaranteed *within a wave*. Recycling lets a later-wave task start as soon as its dependencies are verified, and nothing checks its Own files against tasks still running.
- **Failure it allows:** Task 2.1 owns `api.ts` and starts while 1.2, which also owns `api.ts`, is still live. Two builders edit the same file at once, and one overwrites the other.
- **Fix:** Add to both lines: "…and none of its Own files is owned by a live task."

### H2. Per-task verification can't isolate one task's diff, and it misses new files
- **Where:** `SKILL.md:119`, `references/delegation.md:90`, `references/delegation.md:102`
- **Gap:** `git diff --stat` covers the whole tree. Up to three builders share that tree, and the user's own uncommitted changes may be in it too. `git diff` also skips untracked (newly created) files.
- **Failure it allows:** A task gets passed or failed because of a sibling's edits or the user's existing edits. Any file a builder creates, inside or outside Own, never shows up for the orchestrator or the reviewer.
- **Fix:** Use `git diff --stat -- <Own paths>` + `git status --porcelain` (or `git add -N`), and record dirty files before wave 1.

### H3. The git ban leaves out commands that destroy work in the shared tree
- **Where:** `references/delegation.md:5`, `references/delegation.md:23`
- **Gap:** The banned list is "add, commit, push, tag, reset, stash". `checkout`/`restore`/`clean`/`rebase`/`merge`/`switch` aren't on it. The list is written as a blacklist when it should be an allowlist.
- **Failure it allows:** A builder runs `git checkout -- .` or `git clean -fd` to "start clean" and wipes the work of parallel builders and of the user.
- **Fix:** State it positively: "Git: read-only only (`status`, `diff`, `log`, `show`)."

### H4. The template DO NOT lines leave out the bans that `delegation.md:5` says every brief carries
- **Where:** `references/delegation.md:61` (scout), `:71` (analyst: no deletes/publishing), `:81` (check-runner), `:91` (reviewer)
- **Gap:** Line 5 says every brief's DO NOT line bans git writes, deletes outside Own, and publishing. Four of the five templates leave out some or all of these, and `SKILL.md:111` says to follow "the matching template".
- **Failure it allows:** A check-runner or reviewer (general-purpose, with Bash) gets a brief without the git or publish ban. For example, it may run `npm publish --dry-run`-style scripts or `git stash` to test a clean state.
- **Fix:** Put the shared ban clause into each template's DO NOT line word for word (or into one `BANS:` line that every template includes).

### H5. The escalation ladder has no exit
- **Where:** `SKILL.md:124-127`
- **Gap:** `sonnet ✗ → retry → you diagnose, re-scope or split → re-delegate` loops back to the start with no cap and no hand-off to the user.
- **Failure it allows:** A task that is impossible as specified (for example, the contract is wrong) cycles through re-scope and re-delegate indefinitely, burning tokens and never pausing.
- **Fix:** Add: "If the re-delegated attempt also fails, set Status `Paused` and report to the user."

## Medium

### M1. The fast-lane decision depends on Phase 2 data but is made in Phase 1
- **Where:** `SKILL.md:33-36` vs `SKILL.md:44-53`
- **Gap:** The fast lane needs "≤2 tasks · every task scores ≤2", but tasks are only split and scored in PLAN. GRILL also says to follow `grill-with-docs.md` "exactly", which demands a full interview (`grill-with-docs.md:7`).
- **Failure it allows:** Runs vary. One run grills a one-line rename hard, another guesses "fast lane" for work that later scores 3+ and skips the lock it needed.
- **Fix:** "Before the first question, draft a rough task split and score. If it qualifies, take the fast lane; re-check after PLAN and fall back to the full path if it no longer qualifies."

### M2. The plan file is used in Phase 1 but created in Phase 2
- **Where:** `SKILL.md:24`, `SKILL.md:31` vs `SKILL.md:61`
- **Gap:** GRILL persists the design tree and Status `Grilling` in the plan file, but its path and template only appear later, under PLAN.
- **Failure it allows:** The design tree isn't written until after GRILL, so compaction mid-grill loses it. Or the agent invents its own path/format, which `resume` (`:100`) then can't find.
- **Fix:** Move "Write the plan to `docs/plans/YYYY-MM-DD-<slug>.md`" and its template to the start of Phase 1.

### M3. The condition for skipping the lock is ambiguous
- **Where:** `SKILL.md:37`
- **Gap:** Exit requires "every branch resolved or deferred", so "grilling left no open questions" is true at almost every exit. It's unclear whether it means "no deferred branches" or "asked nothing".
- **Failure it allows:** The separate lock is skipped by default, and the user never confirms scope before the planning work.
- **Fix:** Key it to something observable: "If you asked the user zero questions in GRILL, skip the separate lock."

### M4. Rejecting the plan leaves domain-doc edits made before the gate
- **Where:** `references/grill-with-docs.md:56`, `:60` vs `SKILL.md:101`
- **Gap:** CONTEXT.md and ADRs are written "right away" during GRILL, before the Phase 3 gate. `reject` says "change nothing else", so those edits stay.
- **Failure it allows:** A rejected plan leaves new glossary terms and Accepted ADRs for decisions that were never approved.
- **Fix:** In `reject`: "List CONTEXT.md/ADR edits made this run and ask whether to keep or revert them."

### M5. `resume` picks the wrong plan and doesn't handle in-flight tasks
- **Where:** `SKILL.md:100`, `SKILL.md:10`
- **Gap:** (a) "Newest plan" may be `Complete`/`Rejected`, or one of several plans from the same day. (b) There's no rule for a Log line marked "launched" that has no result: the agent died with the session. (c) Line 10 doesn't send `$ARGUMENTS == resume` to this branch, so `/orchestrate resume` can be grilled as a goal.
- **Failure it allows:** The agent resumes a finished plan, relaunches a task over half-written files, or treats an unverified task as done.
- **Fix:** At line 10, add "`resume` → Control words". Choose "the newest plan whose Status is not Complete/Rejected; ask if there are several". "Launched without a result → inspect its Own diff, then verify or relaunch."

### M6. A retry runs on top of the failed attempt's partial edits
- **Where:** `SKILL.md:124-127`
- **Gap:** The retry brief only adds "the exact error". It doesn't mention the files the failed builder already changed.
- **Failure it allows:** The fresh builder assumes a clean baseline, misreads its own Own files, and stacks fixes on broken partial work.
- **Fix:** "The retry brief includes the current `git diff -- <Own>` and says to start from it."

### M7. A failure in the final full suite has no path
- **Where:** `SKILL.md:129`
- **Gap:** "Run the full Verify with suite" doesn't say who runs it (orchestrator or check-runner) or what to do when it fails, and the escalation ladder is defined per task.
- **Failure it allows:** The orchestrator dumps the full test output into its own context. On failure it fixes the code itself, breaking "never implement", or closes with a red suite.
- **Fix:** "Run it via a check-runner. On failure, map each error to its owning task and re-enter that task's escalation."

### M8. Contradictions about tier and reading
- **Where:** `SKILL.md:30` vs `:57`; `SKILL.md:57` vs `:119`
- **Gap:** (a) Line 30 allows a sonnet scout for cross-module synthesis, but line 57 says pure read/summarize work is "always haiku". (b) Line 57 says to review security work "line by line", but line 119 says "read hunks only where the digest or review points".
- **Failure it allows:** The agent picks whichever line it read last. Security diffs get skim-reviewed, or synthesis scouts are under-tiered.
- **Fix:** In line 57, add "except cross-module synthesis". In line 119, add "security/migration tasks: read the full diff".

### M9. "End your turn" vs "draft the next briefs while agents run"
- **Where:** `SKILL.md:107` vs `SKILL.md:112`
- **Gap:** Once the turn ends there is no "while agents run" in which to work. The two lines can't both be followed.
- **Failure it allows:** The agent either stays in the turn and polls, or never drafts ahead, which adds latency between waves.
- **Fix:** "Before ending your turn, draft the next wave's briefs into the plan file."

### M10. Builder briefs don't ban destructive commands
- **Where:** `references/delegation.md:23` vs `SKILL.md:144`
- **Gap:** The guardrail asking for confirmation before destructive or irreversible actions binds only the orchestrator. The builder DO NOT line doesn't cover migrations against real data, DB resets, or force operations.
- **Failure it allows:** A builder runs `db:migrate`/`db:reset` against a configured real DB as part of "make the check pass".
- **Fix:** Add to the shared bans: "no commands that touch real data or external services; report and stop instead."

### M11. The "never implement" discipline rule has no rationalization counter
- **Where:** `SKILL.md:14`, `:129`, `:142`
- **Gap:** This is a discipline rule, stated three times. There's no red-flags list or rationalization table (writing-skills: "Bulletproofing"), and the ≤5-line exception is the obvious loophole.
- **Failure it allows:** "It's 4 lines, faster myself" gets applied to *new* work, or repeated across several "tiny fixes" per task.
- **Fix:** State the rule once, and add a 3–4 row table: "only 5 lines" / "faster myself" / "the builder will get it wrong" → "delegate; the exception is one VERIFY fix per task".

## Low

### L1. The description summarizes the workflow
- **Where:** `SKILL.md:3`
- **Gap:** The description lists the steps (grill → preview → delegate → verify) and implementation details (Haiku/Sonnet, max 3), against the writing-skills SDO rule. The impact is low because `disable-model-invocation: true`.
- **Fix:** "Manual only: `/orchestrate <goal>` or `/orchestrate resume`, to plan and run a multi-task build via sub-agents."

### L2. Approval words are an exact list
- **Where:** `SKILL.md:96`
- **Gap:** "approved", "looks good" and "ship it" count as edit requests.
- **Failure it allows:** The preview loop re-renders with no changes.
- **Fix:** "Unconditional approval in any words; if unsure, ask."

### L3. "Other" free text triggers a delta preview before any preview exists
- **Where:** `SKILL.md:28`
- **Gap:** During GRILL there's no preview yet to diff against.
- **Fix:** "During GRILL, record it in Open questions; delta previews apply after Phase 3."

### L4. The fast-lane plain prompt has no REPORT shape
- **Where:** `SKILL.md:35`, `:111`
- **Gap:** Only the DO NOT bans are kept. VERIFY step 3 reads "the builder's compact report", which the brief never asked for.
- **Fix:** "A plain prompt + the DO NOT line + the REPORT block."

### L5. Checks the orchestrator runs itself can flood its context
- **Where:** `SKILL.md:117`, `:119`
- **Gap:** Line 12 calls context the scarcest resource, yet re-running a check has no output cap. A task with zero checks (docs) has no "key check".
- **Fix:** "Pipe through `tail -n 30`; with no check command, verify via the diff only."

### L6. Duplication against single-source-of-truth
- **Where:** `SKILL.md:110` = `delegation.md:106`; `SKILL.md:30` ≈ `delegation.md:99`; `SKILL.md:28` ("one question", "recommended") ≈ `grill-with-docs.md:7,9`; `SKILL.md:32` ≈ `grill-with-docs.md:58` ≈ `CONTEXT-FORMAT.md:3`; `SKILL.md:118` "security-sensitive" is redundant (security is already ≥sonnet, `:57`)
- **Failure it allows:** A later edit changes one copy and leaves the others stale.
- **Fix:** Keep each rule in one file and turn the other copies into pointers.

### L7. Two exit criteria for grilling
- **Where:** `grill-with-docs.md:7` ("until you share one understanding") vs `SKILL.md:37` ("every branch resolved or deferred")
- **Gap:** The reference's fuzzy bound invites premature completion. The SKILL's bound is checkable.
- **Fix:** Delete the clause in the reference and point to the Exit rule.

### L8. Where a term goes in a multi-context repo is unspecified
- **Where:** `grill-with-docs.md:44`, `ADR-FORMAT.md:3`
- **Gap:** With `CONTEXT-MAP.md` present, nothing says which `CONTEXT.md` gets a new term. ADR numbering is per folder, so "Superseded by NNNN" is ambiguous across folders.
- **Fix:** "Put a term in the context that owns it (per CONTEXT-MAP); cite cross-folder ADRs by path."

### L9. A superseding ADR has no back-link
- **Where:** `ADR-FORMAT.md:8`, `:23`
- **Gap:** The old ADR gets `Superseded by`, but the new one has no `Supersedes` field.
- **Fix:** Add `- Supersedes: NNNN (optional)` to the template.

### L10. Sprawl
- **Where:** `SKILL.md` (1,760 words)
- **Gap:** This is well above writing-skills' <500-word target. Phase 4–5 mechanics (git fallback, slot recycling, escalation) are needed only after the gate, so they could be disclosed.
- **Fix:** Move the EXECUTE/VERIFY mechanics into `references/execution.md`, behind a pointer read at Phase 4.

### L11. Briefs lean on negation
- **Where:** `references/delegation.md:23-24`, `:61`, `:71`, `:81`, `:91`
- **Gap:** The DO NOT lists are long, and there's "Don't improvise". writing-for-agents says to prefer the positive target. Only "Own (may edit)" is phrased positively.
- **Fix:** Lead with a positive line, "Edit only Own; run only the listed commands", and keep a short ban list as the hard guardrail.

### L12. The baseline commit vs the commit guardrail
- **Where:** `SKILL.md:105` vs `:141`
- **Gap:** "The one allowed commit prompt" isn't reconciled with "commits need a user request in this run".
- **Fix:** At line 141, add "(the baseline commit after a yes at Phase 4's git check counts as requested)".

## Not checkable statically

- writing-skills Iron Law / RED-GREEN (baseline pressure runs, micro-tests against a no-guidance control): no evidence could be checked without reading `docs/audits/` / `docs/plans/`, which this review excluded.
- The checklist items "Quick reference table" and "Common mistakes section" are absent from `SKILL.md`. M11 covers the one that matters.
