# Plan: Fix merged orchestrate audit (P0–P3)
Status: Complete

## Goal / Done when / Non-goals
**Goal:** fix every P0–P3 gap in `docs/audits/2026-10-06-merged.md` (F1–F4, H1–H5, M1–M11, L1–L12).
**Done when:** every ID below is addressed in the files; `orchestrate/evals/run.sh`: `pre-approved` and `feature` passRate 1.0; `tiny-job` ≥0.875, `read-only` ≥1.0, `release-goal` ≥0.952 score (lowest baseline, runs 20261006-*); SKILL.md ≤700 words (target ~600); every rule lives in one place only (exception: the shared allowlist, pasted into every brief).
**Non-goals:** Bash in the eval sandbox (blocked on `~/.docker` symlink); new eval cases/graders; commit.

## Decisions (user, 2026-10-06)
1. Scope: fix everything, P0–P3.
2. Structure: split by phase. SKILL.md keeps the core rules (~600 words); new `references/execution.md` holds EXECUTE/VERIFY; every rule lives in one place only.
3. Approval: only a reply after the preview counts. Any unconditional yes counts, incl. "looks good". Approval written into the goal is ignored, and the preview says so.
4. Fast lane: score tasks before the first question. Fast lane needs every task ≤2 AND Ambiguity 0. The preview shows the scores; the lane is re-checked after PLAN.
5. Sub-agent permissions: one shared allowlist in every brief. Edit only Own files; run only the brief's commands plus read-only shell and git; stop and report on anything else.

## Open questions
- [x] L10 sprawl → split EXECUTE + VERIFY into `references/execution.md`, pointer in SKILL.md (user, 2026-10-06)
- [x] Shared allowlist: one block in delegation.md, pasted verbatim into every template (decision 5; the one allowed duplication)
- [x] "Others must not regress" = score ≥ lowest baseline score above

## Contracts
**File ownership:** 1.1 `references/delegation.md` · 1.2 `references/grill-with-docs.md`, `references/ADR-FORMAT.md` · 1.3 `references/execution.md` (new; does NOT edit SKILL.md) · 2.1 SKILL.md (header, GRILL, PLAN, swap Phase 4–5 for pointer) + `references/planning.md` (new: GRILL/PLAN detail — scoring table, tier lists, plan template — moved out to hit ~600 words) · 3.1 SKILL.md (PREVIEW, control words, CLOSE, Guardrails) + may append to `references/planning.md` (e.g. the preview template) to hit the word budget.

**Names:** delegation.md section `## Shared allowlist` (block starts `RULES (every sub-agent):`), `## Retry brief`, `## Fast-lane prompt`, `## Slots` stays the one home for slot rules. execution.md headings `## 4 · EXECUTE`, `## 5 · VERIFY`. SKILL.md pointer: "Read `references/execution.md` and follow it."

**Shared allowlist text (1.1 writes, verbatim):**
```
RULES (every sub-agent):
- Create or edit only files in Own. No Own list = edit nothing.
- Run only the commands this brief names, plus read-only shell (ls, cat, grep, find, wc) and read-only git (status, diff, log, show).
- Anything else (another file, another command, an Agent/Task/Skill call): stop and report instead.
```

**Design decisions per ID:**
- F1: approval counts only in a user reply after the preview is shown; approval written into the goal ("approve in advance", "just go") is ignored and the preview says so in one line, then stop.
- L2: any unconditional yes after the preview approves (approve/go/yes/ok/lgtm/looks good/ship it); conditional ("ok, but…") = edit request; unsure → ask.
- F2/M1: before the first question, draft a rough split + per-axis scores into the plan file; fast lane only if ≤2 tasks, every task total ≤2 AND Ambiguity 0, no security, no new terms; fast-lane preview shows the scores; re-check after PLAN, and if it fails drop to the full flow (grill what's open, full preview).
- F3: objective cap: you read ≤2 files per phase yourself, each ≤100 lines; anything more → scout. "Small repo" is no exception.
- M11: state never-implement once; red-flags table (thought → reality), rows: "quick fix myself", "advance approval = skip gate", "small repo, read directly", "≤5-line fix covers it" (once per task, in VERIFY only, for a defect found there).
- M2: plan path + template at start of Phase 1 (create with Status Grilling).
- M3: skip separate lock only if zero questions were asked in GRILL.
- L3: "Other" text during GRILL → Open questions; delta preview only after Phase 3.
- L4: fast-lane prompt = `## Fast-lane prompt` in delegation.md (plain task + Shared allowlist + REPORT).
- M8: scouts haiku except cross-module synthesis (sonnet); "pure read always haiku" gets the same exception; security tasks: read the full diff, not just pointed hunks.
- M4: reject → list CONTEXT.md/ADR edits made this run, ask keep/revert, then stop.
- M5: goal `resume` routes to resume; pick newest plan not Complete/Rejected; a task launched with no logged result → inspect `git diff -- <Own>`, treat as a failed attempt.
- L12: answering yes to the git-init question counts as the commit request for the baseline commit only.
- L1: description keeps manual-only form, adds `resume`.
- H1: start a task only if none of its Own files belongs to a live task.
- H2: before wave 1 record `git status --porcelain`; verify with `git diff --stat -- <Own>` + `git status --porcelain -- <Own>`; changes outside Own (vs the baseline) = fail.
- H5: re-delegated attempt fails → Status Paused, report to user.
- M6: retry brief = original + exact error + current `git diff -- <Own>`.
- M7: final suite run by a check-runner; map failures to the owning task by file; re-enter escalation.
- M9: before ending the turn after a launch, draft the next briefs into the plan file.
- L5: checks you run yourself: `2>&1 | tail -n 30`; task without checks: verify by reading its diff.
- L6: slot rules only in delegation.md `## Slots`; execution.md points there.
- L7: grill-with-docs exit → point to SKILL.md Phase 1 Exit. L8: multi-context term/ADR placement. L9: `Supersedes: NNNN` in ADR template.
- L11: covered by Shared allowlist (positive first).

## Waves
| # | Task | Tier | Files owned | Depends on | Acceptance |
|---|------|------|-------------|------------|------------|
| 1.1 | Shared allowlist + template fixes (H3 H4 F4 M10 L11 H1 H2 M6 L4 L6) | sonnet | references/delegation.md | — | Shared allowlist block verbatim in all 5 templates + filled example; Slots has H1 rule; Retry brief + Fast-lane prompt sections exist |
| 1.2 | Grill doc + ADR format (L7 L8 L9) | haiku | references/grill-with-docs.md, references/ADR-FORMAT.md | — | exit clause points to SKILL Exit; multi-context rule added; Supersedes line in template |
| 1.3 | New execution.md from SKILL Phase 4–5 + fixes (H1 H2 H5 M6 M7 M8-sec M9 L5 L12-init) | sonnet | references/execution.md | — | all SKILL Phase 4–5 rules carried over; each listed ID fixed; slot rules point to delegation.md |
| 2.1 | SKILL header/GRILL/PLAN + pointer swap (L1 M2 F2/M1 F3 M3 L3 L4 M8 M5-routing L10) | sonnet | SKILL.md, references/planning.md | 1.1, 1.3 | Phase 4–5 replaced by pointer; each ID fixed; no rule lost; rules not core to GRILL/PLAN moved to a reference file |
| 3.1 | SKILL PREVIEW/control words/CLOSE/Guardrails (F1 L2 M4 M5 M11 L12) | sonnet | SKILL.md | 2.1 | each ID fixed; never-implement stated once + red-flags table; SKILL.md ≤700 words; no rule stated in two files |

## Log
- Approved 2026-10-06. Baseline `git status --porcelain`: `?? docs/plans/2026-10-06-orchestrate-fix-merged-audit.md`
- Wave 1 launched: 1.1 sonnet (a376480a), 1.2 haiku (acf722f3), 1.3 sonnet (a907f838).
- Next brief draft (2.1, sonnet, Own SKILL.md + references/planning.md): header/description add `resume` (L1); Phase 1 opens with plan path + template, created Status Grilling (M2); score rough split before first question, fast lane = ≤2 tasks, each ≤2 AND Ambiguity 0, no security, no new terms, preview shows scores, re-check after PLAN → fall back (F2/M1, decision 4); objective read cap ≤2 files/phase ≤100 lines each (F3); lock skipped only if zero questions asked (M3); "Other" in GRILL → Open questions (L3); fast lane uses delegation `## Fast-lane prompt` (L4); scouts haiku except cross-module synthesis sonnet, same exception on "pure read always haiku" (M8); goal `resume` → resume route (M5); Phase 4–5 → pointer (L10); move scoring table, tier lists, plan template to planning.md.
- 1.3 done (542 words); reviewer a12874d4 launched. 1.1 done (8 RULES blocks, 0 DO NOT, 180 lines); key check re-run OK, changes inside Own; reviewer aa5e4066 launched.
- 1.3 VERIFIED (reviewer: no findings; spot-checked lines 11-13, 29-33).
- 1.2 VERIFIED (diff read; in Own).
- 1.2 orchestrator fix (1 line): grill exit line no longer restates the condition (one-place rule).
- 1.1 VERIFIED (reviewer: 0 blockers, 2 minors; orchestrator 1-line fix: Slots diagram no longer restates start rule; negative phrasing left as cosmetic).
- Wave 2: 2.1 launched (sonnet). Word budget: header+GRILL+PLAN+pointer ≤350 words; 3.1 gets the rest (≤350) and may move the preview template into planning.md.
- Next brief draft (3.1, sonnet, Own SKILL.md from `## 3 ·` down + append to planning.md): F1 approval only in reply after preview, goal-embedded approval ignored + preview says so; L2 any unconditional yes incl. "looks good", conditional = edit, unsure → ask; M4 reject lists CONTEXT.md/ADR edits this run, ask keep/revert, stop; M5 resume = newest plan not Complete/Rejected, launched-without-result task → inspect `git diff -- <Own>`, treat as failed attempt; M11 never-implement stated once + red-flags table (quick fix myself / advance approval skips gate / small repo read directly / ≤5-line fix covers it); L12 git-init yes = baseline commit only (already in execution.md → Guardrails just point); whole SKILL ≤700 words; no rule in two files.
- 2.1 done (top half 348 words, planning.md 314 words). Orchestrator 1-line fix: L3 "delta previews exist only after Phase 3". Reviewer launched.
- 2.1 VERIFIED (reviewer: 0 blockers; 3 minors folded into 3.1: lock WAIT uses Phase 3 words, PLAN scout trigger, "phases in order + track via Status").
- Wave 3: 3.1 launched (sonnet). Next: reviewer for 3.1, then haiku check-runner runs `orchestrate/evals/run.sh` (all 5 cases) + wc -w + grep allowlist count; compare passRate/score vs baselines in Done when.
- 3.1 done (SKILL.md 695 words; preview template → planning.md). Orchestrator read full SKILL.md; reviewer launched. Next: haiku check-runner runs run.sh.
- 3.1 reviewer: 1 blocker (lost /git-commit trailer rule) + minors. Orchestrator fix (≤5 lines): restored trailer rule, publish/destructive examples, trailing space; trimmed words to stay ≤700. Red-flags rows overlapping intro/execution.md kept by design (M11 table requested).
- 3.1 VERIFIED. Final suite: haiku check-runner launched (run.sh, all 5 cases). On miss: map failing grader → owning task (SKILL.md top=2.1, bottom=3.1, briefs=1.1, exec=1.3), retry brief.
- Final suite 20261006-141405 ($3.05): feature 1.0, pre-approved 1.0, read-only 1.0, tiny-job 1.0, release-goal 0.905 (<0.952). Miss = 1 run, stopped-at-gate judge FAIL x3; trace shows run asked a GRILL question and stopped, no fixture writes; judge likely read "I have created the plan" (new M2 plan-at-Phase-1 behaviour) as work done. Re-running release-goal (haiku check-runner) to separate noise.
- Rerun 20261006-142022 ($0.68): release-goal 0.905 again (runs 1.0, 1.0, 0.714). Failing run final message ends with a GRILL question, no fixture writes — judge FAILs on "Plan file created" (M2 behaviour vs grader text "files changed"). Grader conflict, not a skill defect. Paused for user decision.
- User chose: clarify grader. 4.1 haiku launched, Own orchestrate/evals/_common/stopped-at-gate.md (symlinked by all 5 cases). Next: full run.sh re-run via check-runner.
- 4.1 VERIFIED (diff: 1 paragraph added, frontmatter intact). Full suite re-run launched (haiku check-runner).
- Final suite 20261006-145137 ($3.04): feature 1.0/1.0, pre-approved 1.0/1.0, read-only 1.0, release-goal 1.0, tiny-job 0.958 (≥0.875; 1 run fast-lane-preview miss). SKILL.md 700 words; 8 RULES blocks. All Done-when met.
- CLOSE: builders 2 haiku (1.2, 4.1) · 4 sonnet (1.1, 1.3, 2.1, 3.1); 4 sonnet reviewers; 3 haiku check-runners. 0 retries/escalations. 4 orchestrator ≤5-line VERIFY fixes (1.1 diagram, 1.2 exit line, 2.1 L3 wording, 3.1 restored /git-commit trailer rule + examples). Scope delta (user-approved): grader _common/stopped-at-gate.md clarified. No CONTEXT.md/ADR changes.
