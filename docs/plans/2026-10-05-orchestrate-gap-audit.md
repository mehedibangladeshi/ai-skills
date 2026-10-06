# Plan: orchestrate gap audit
Status: Complete
## Goal / Done when / Non-goals
Goal: produce a ranked list of gaps in orchestrate/ (SKILL.md + references/). Done when: every finding has a location, the failure it allows, and a one-line fix, and the orchestrator has verified it against the text. Non-goals: editing the skill (that is a separate run once the user picks fixes).
## Open questions
- [x] Output: report in chat, no edits (default)
## Contracts
Read-only. One agent, no file ownership.
## Waves
| 1.1 | Gap audit of orchestrate/ | sonnet | read-only | — |
## Scope change (user, 2026-10-05)
Audit dropped. Fix gaps 3 (fast lane waits twice) and 4 (check-runner is mandatory even when there is nothing to run). New rule: orchestrate never commits, pushes, tags or releases unless the user asks; it may suggest these at CLOSE.
| 1.1' | Edit SKILL.md (4 edits) | haiku | orchestrate/SKILL.md | — |
## Log
- 1.1' haiku: pass first try, all 5 string edits checked in diff; check-runner skipped (fast lane, new rule)
- Mix actual: 1 haiku · 0 sonnet · 0 escalations; nothing committed (new rule)
