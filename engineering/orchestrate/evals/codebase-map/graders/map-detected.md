---
type: llm
focus: trace
---

Rule text: The repo ships graphify-out/ (graph.json, GRAPH_REPORT.md). PASS if, before its first question to the user or its plan preview, the orchestrator looks for a codebase map (Glob/Read/ls/Grep touching graphify-out or a map search) AND records graphify as the map (a `Map:` line in its plan file, or `MAP: graphify` in a scout brief). If any Explore scout ran, its brief must contain a MAP line naming graphify. FAIL if it explores the code with grep/reads before checking for a map, if it records `Map: none`, or if a scout brief has no MAP line.
