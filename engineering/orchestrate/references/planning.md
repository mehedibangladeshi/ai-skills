# Planning

## Plan file

`docs/plans/YYYY-MM-DD-<slug>.md`, created in GRILL. After deciding the lane, record the actual planner and eligible workers. For local PLAN (always on the fast lane), use the host's provider or `Planner: host` on `other`. Keep the allowed providers and drop log even in a fast-lane stub.

```markdown
# Plan: <title>
Status: Grilling | Awaiting approval | Executing (wave N) | Verifying (wave N) | Complete | Paused | Rejected
Host: <claude|codex|other> · Planner: <claude|codex|host> · Providers: claude+codex | <one>
Allowed providers: claude+codex | <single-provider selection>
## Goal / Done when / Non-goals
## Open questions
Design tree, ticked off during grilling.
## Contracts
Interfaces, types, file ownership.
## Waves
Same table as the preview.
## Log
One line per provider drop (provider, reason), launch (task, tier, agent ID), result, retry or escalation.
```

## Steps

**Planner handoff (host only).** Follow `references/providers.md` `## Flags`. Outside the fast lane, if the flag selects a different eligible planner, send only the lock (drafted if zero questions were asked), scout digests and this `## Steps` section to its deep CLI. The recipient skips host-only steps and returns just the waves table and contracts in one call.

1. **Contracts first.** Fix shared interfaces, types, names and file ownership first, so parallel agents never guess or collide.
2. **Split** the work into tasks one agent can finish in one run. If acceptance criteria don't fit in 3 bullets, split.
3. **Score and tier** each task, 0–2 per axis:

   | Axis | 0 | 1 | 2 |
   |---|---|---|---|
   | Ambiguity | exact steps | pattern to follow | design choices |
   | Breadth | 1 file | 2–4 files | 5+ files / cross-module |
   | Reasoning | mechanical | local logic | subtle: concurrency, security, debugging |

   Total **0–2 → `light`**, **3–4 → `standard`**, **5–6 → split or settle the design yourself (in the plan, not in code) until every piece is ≤4**. If a split would break coherence (subtle debugging, cross-module design, concurrency), run the task whole on `deep`. If the user explicitly asks for deep (for a task or the whole run), use `deep`.
   - *light:* scouting, summaries, renames, boilerplate, config, docs, tests that follow an existing pattern, one-file edits with exact steps
   - *standard:* multi-file features, non-trivial logic, refactors, debugging with a known repro, new test suites
   - *deep:* anything on the security surface, 5–6 score tasks that cannot be split coherently, tasks the user asked to run on deep

   **Security surface:** auth/authz, sessions, crypto, secrets/keys, input validation at trust boundaries, injection-prone code (SQL, shell, HTML), user-controlled file/path handling, permissions, dependencies with CVEs, any security audit or review.

   Overrides: a task touching the security surface is always `deep`; tag it in the plan with a one-line reason, and review it line by line. Route it per `references/providers.md` `## Security`. Data-migration work is `standard` at minimum. Pure read or summarize work is `light`, except cross-module synthesis (`standard`) and security work (`deep`). When unsure, pick the lower tier: escalating costs less than over-provisioning. Overrides beat the pick-lower rule.
4. **Group into waves** of up to 5 independent tasks. Each file has exactly one owner in its wave.
5. **Cut low-gain work.** Mark it optional or drop it.
6. **Route and check budget (host only).** Before the preview, including on the fast lane, run `python3 -I <skill dir>/scripts/lane.py budget` once for eligible providers (`--only <provider>` when one remains). Assign providers per `references/providers.md` `## Routing and budget`. Use the result for the `Parallel` and `Deep` lines.

## Preview template

```markdown
## Plan preview: <title>
**Goal:** … · **Done when:** … · **Out of scope:** …
**Decisions:** ADR NNNN <title>, … · **GLOSSARY.md:** <n> terms added/changed

| # | Task | Tier | Provider | Files owned | Depends on | Acceptance |
|---|------|------|----------|-------------|------------|------------|
| 1.1 | … | <tier> → <model> | <provider> | … | — | … |

Record a reason for every deep row in the plan (security surface, unsplittable score of 5–6, or user request).

**Orchestrator-only:** contracts, verification (integration work is a task row)
**Verify with:** <test / lint / typecheck / build commands>
**Risks:** <top 1–3 + mitigation>
**Mix:** <a> light · <b> standard · <c> deep · <n> waves · <x> claude / <y> codex
<provider> unavailable: <reason> (only when a provider was dropped; if it was the selected planner, note that the host plans)
**Parallel:** <only if offering 5 slots under providers.md ## Slots: reply "slots 5" to opt in; plain go keeps 3>
**Deep:** <only if more than 2 deep tasks: list each reason and the budget note. Ask for deep confirmation per providers.md ## Deep tasks unless only mandatory security rows push the count over 2>
**Model:** <only if security tasks are present and the host model is standard-tier: suggest switching to a deep model; never switch models yourself>

Approve, edit, or reject?
```
