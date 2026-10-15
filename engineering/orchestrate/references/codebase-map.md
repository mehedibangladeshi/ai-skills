# Codebase map

A pre-built map (symbols, calls, imports, dependencies) is cheaper than reading raw files. Detect it once; sub-agents use it.

## Orchestrator: detect once

At GRILL step 2, before the first question. Use Glob/Grep/ls (Bash may be unavailable). Several maps may exist; use all.

1. Own tool list: MCP tools naming a code/knowledge graph, symbols, references, call chains, impact/blast radius, neighbors, shortest path, repo map (`query_graph`, `get_neighbors`, `shortest_path`, `detect_impact`, `find_symbol`, `find_referencing_symbols`).
2. Glob repo root for map output: `graphify-out/` (`graph.json`, `GRAPH_REPORT.md`), hidden index dirs of CodeGraph, GitNexus, code-review-graph, Serena.
3. Grep `CLAUDE.md`, `AGENTS.md`, `.cursorrules` for "knowledge graph", "code graph", "use it first".
4. A documented graph CLI (e.g. `graphify query`).

- Do not read `GRAPH_REPORT.md` yourself (read cap). The scout orients.
- Freshness: compare map file mtime or report date with `git log -1 --format=%cI`. No Bash to run git: mark `possibly stale`. In doubt, same.
- Record one line in the plan Log/Contracts and paste it into every scout and analyst brief. Builders get it only when they must locate code themselves.
  `MAP: <tool> — <how to query> (fresh | possibly stale)`
- Name the exact allowed tools/commands in the brief; sub-agents run only what it names. e.g. `graphify query "<q>"`, `graphify path "A" "B"`, `graphify explain "X"`, or the MCP tool names.
- Nothing found: `MAP: none`. Normal flow; do not ask the user.
- Never build, install, or refresh a map. Incremental update only if the user asked in this run: you run it via Bash after confirming, never a sub-agent. No Bash: tell the user instead.
- Fast lane skips map detection (no MAP slot in its prompt).
- CLOSE: no map existed and exploration was heavy → one optional follow-up line: a code map could make future runs cheaper.

## Sub-agent: use the map

When `MAP` is not none, paste at least the condensed block from the Scout/Analyst template into the brief; sub-agents never read this file.

- Orient: read the report/summary if present. Locate: query/search/symbol tools for the entities. Trace: neighbors, paths, callers, impact (before proposing a change, if supported). Read only the files the map named.
- Best tool per question: architecture, "how does X work", dependencies → graph tool; exact definitions, references, renames → symbol/LSP tool; fuzzy "where is code that does X" → semantic search.
- Two tools disagree: trust the fresher; confirm in source.
- The map is never sole evidence: confirm every reported fact in source with `path:line`.
- Map miss or contradiction: fall back to grep/glob; flag "possibly stale".
- Edges marked inferred or ambiguous are hints; verify.
- Never build, install, or refresh the map.
- Mention the map in the report only when it affects trust ("per graph, possibly stale").
