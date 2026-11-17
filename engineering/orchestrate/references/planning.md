# Planning

## Plan file

`docs/plans/YYYY-MM-DD-<slug>.md`, created in GRILL:

```markdown
# Plan: <title>
Status: Grilling | Awaiting approval | Executing (wave N) | Verifying (wave N) | Complete | Paused | Rejected
## Goal / Done when / Non-goals
## Open questions   — design tree, ticked off during grilling
## Contracts        — interfaces, types, file ownership
## Waves            — same table as the preview
## Log              — one line per launch (task, tier, agent ID), result, retry, escalation
```

## Steps

1. **Contracts first.** Fix shared interfaces, types, names and file ownership first, so parallel agents never guess or collide.
2. **Split** the work into tasks one agent can finish in one run. If acceptance criteria don't fit in 3 bullets, split.
3. **Score and tier** each task, 0–2 per axis:

   | Axis | 0 | 1 | 2 |
   |---|---|---|---|
   | Ambiguity | exact steps | pattern to follow | design choices |
   | Breadth | 1 file | 2–4 files | 5+ files / cross-module |
   | Reasoning | mechanical | local logic | subtle: concurrency, security, debugging |

   Total **0–2 → `haiku`**, **3–4 → `sonnet`**, **5–6 → split or settle the design yourself (in the plan, not in code) until every piece is ≤4**. If a split would break coherence (subtle debugging, cross-module design, concurrency), run the task whole on `opus`. If the user explicitly asks for opus (for a task or the whole run), use `opus`.
   - *haiku:* scouting, summaries, renames, boilerplate, config, docs, tests that follow an existing pattern, one-file edits with exact steps
   - *sonnet:* multi-file features, non-trivial logic, refactors, debugging with a known repro, new test suites
   - *opus:* anything on the security surface, 5–6 tasks that cannot be split coherently, tasks the user asked to run on opus

   **Security surface:** auth/authz, sessions, crypto, secrets/keys, input validation at trust boundaries, injection-prone code (SQL, shell, HTML), user-controlled file/path handling, permissions, dependencies with CVEs, any security audit or review.

   Overrides: a task touching the security surface is `opus`, always; tag it in the plan with a one-line reason, and you review it line by line. Data-migration work is `sonnet` at minimum. Pure read or summarize work is always `haiku`, except cross-module synthesis (`sonnet`). When unsure, pick the lower tier: escalating costs less than over-provisioning. Overrides beat the pick-lower rule.
4. **Group into waves** of at most 3 independent tasks. In a wave, each file has exactly one owner.
5. **Cut low-gain work.** Mark it optional or drop it.

## Preview template

```markdown
## Plan preview: <title>
**Goal:** … · **Done when:** … · **Out of scope:** …
**Decisions:** ADR NNNN <title>, … · **CONTEXT.md:** <n> terms added/changed

| # | Task | Tier | Files owned | Depends on | Acceptance |
|---|------|------|-------------|------------|------------|
| 1.1 | … | haiku | … | — | … |

Every opus row's Tier cell carries its reason: `opus (security: <surface>)`, `opus (5-6 unsplittable)` or `opus (user asked)`.

**Orchestrator-only:** contracts, verification (integration work is a task row)
**Verify with:** <test / lint / typecheck / build commands>
**Risks:** <top 1–3 + mitigation>
**Mix:** <x> haiku · <y> sonnet · <z> opus · <n> waves (x + y + z must equal the task count)
**Opus:** <only if more than 2 opus tasks: ask the user to confirm opus specifically>
**Model:** <only if security tasks are present and the orchestrator runs on Sonnet: suggest `/model` Opus; never switch models yourself>

Approve, edit, or reject?
```
