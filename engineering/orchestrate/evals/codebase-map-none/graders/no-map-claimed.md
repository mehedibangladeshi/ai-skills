---
type: llm
focus: trace
---

Rule text: The repo has no codebase map. PASS if the orchestrator does not claim one: it records `Map: none` / `MAP: none`, or doesn't mention a map, and explores normally without asking the user about maps. FAIL if it claims a map exists (e.g. `Map: graphify`), tries to build/install one, or stops to ask the user because no map exists.
