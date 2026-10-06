# Plan: orchestrate full audit
Status: Complete
## Goal / Done when / Non-goals
Goal: run a full audit of orchestrate/ (SKILL.md + 4 references). Done when: docs/audits/2026-10-05-orchestrate-audit.md holds deduped findings with IDs, ranked by severity, each with file:line, the failure it allows, and a one-line fix, all verified by the orchestrator, and a top-10 summary is in chat. Non-goals: editing the skill; committing.
## Open questions
- [x] Output: report only (user)
- [x] Angles: internal consistency, references vs SKILL.md, harness fit, real-run evidence, guardrails, context/token efficiency, proper tool usage, simple trigger/command words, easy for agents/models (user)
- [x] Location: file + chat summary, uncommitted (user)
## Contracts
- Auditors are read-only and touch no files. Each finding is reported as: `[sev high|med|low] [angle] file:line — gap — failure it allows — one-line fix`, ≤12 findings per auditor.
- Orchestrator (verification): checks every cited file:line, dedupes, ranks, assigns IDs G01…
- 2.1 owns docs/audits/2026-10-05-orchestrate-audit.md (the only file written).
## Waves
| 1.1 | Audit A: internal consistency, guardrails, references vs SKILL.md | sonnet | read-only | — |
| 1.2 | Audit B: harness fit, tool usage, real-run evidence | sonnet | read-only | — |
| 1.3 | Audit C: context/token efficiency, trigger words, ease for agents/models | sonnet | read-only | — |
| 2.1 | Write the audit file from the verified list | haiku | docs/audits/2026-10-05-orchestrate-audit.md | 1.1–1.3 verified |
## Log
- wave 1 launched: 1.1, 1.2, 1.3 (sonnet, general-purpose, read-only briefs)
- 1.1/1.2/1.3 sonnet: pass, 36 raw findings; citations spot-checked; deduped to 25 (4 high, 15 med, 6 low), 3 rejected
- wave 2 launched: 2.1 haiku writes the audit file
- 2.1 haiku: pass, 25 IDs in order, verified by orchestrator
- Mix actual: 1 haiku · 3 sonnet · 0 escalations; reviewer/check-runner N/A (no diff, see G01)
