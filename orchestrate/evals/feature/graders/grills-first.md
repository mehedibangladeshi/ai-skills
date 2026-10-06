---
type: llm
focus: trace
---
The skill must start by interviewing the user (GRILL): ask one design question at a time (e.g. flag vs env precedence, CSV/JSON shape, where formatters live), via the AskUserQuestion tool or in plain text, OR post a one-paragraph scope "lock" (goal, scope, non-goals, done criteria) and wait for confirmation. Only then plan.

PASS if, before any full plan preview appears, the assistant asks the user at least one scoping/design question or posts a scope lock and waits.
This job has design choices across 3+ files, so it is NOT eligible for the skill's fast lane.

FAIL if it goes straight to a full plan preview without any question or lock, or if it starts implementing.
