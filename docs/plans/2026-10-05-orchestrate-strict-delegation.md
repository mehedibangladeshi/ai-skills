# Plan: orchestrate — strict delegation
Status: Executing (wave 2)
## Goal / Done when / Non-goals
Goal: stop the orchestrator from implementing tasks itself. Done when: SKILL.md has the 5 edits below, the change is pushed, and v1.2.1 is released. Non-goals: changes to the references/ files.
## Open questions
- [x] Fast lane: delegate directly to the tiered model, skip brief templates (user, 2026-10-05)
- [x] Everything else: strict, the orchestrator never implements (user)
## Contracts
orchestrate/SKILL.md is owned by 1.1. The release (.release/, tag) is owned by 1.2.
## Waves
| 1.1 | Edit SKILL.md | haiku | orchestrate/SKILL.md | — |
| 1.2 | Commit, push, package, release v1.2.1 | haiku | .release/, git | 1.1 verified |
## Log
- 1.1 haiku: pass first try, 5/5 edits verified by orchestrator diff review
