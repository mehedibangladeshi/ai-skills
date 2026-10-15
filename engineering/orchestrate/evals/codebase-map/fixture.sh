#!/usr/bin/env bash
# Codebase-map fixture: the shared fixture plus a committed graphify-out/ map.
set -e
bash "$(dirname "$0")/../fixture.sh"
mkdir -p graphify-out
cat > graphify-out/GRAPH_REPORT.md <<'MD'
# Graph Report

## God nodes
- `foo` (utils.sh) - degree 2, called by report.sh

## Connections
- `report.sh` -> `foo` (calls, EXTRACTED)
- `tests/test_report.sh` -> `report.sh` (calls, EXTRACTED)

## Communities
- **reporting**: report.sh, tests/test_report.sh, foo

## Suggested questions
- how is the report total computed?
MD
cat > graphify-out/graph.json <<'JSON'
{
  "nodes": [
    {"id": "utils.sh:foo", "label": "foo", "file": "utils.sh", "community": "reporting"},
    {"id": "utils.sh:avg", "label": "avg", "file": "utils.sh", "community": "reporting"},
    {"id": "utils.sh:first_line", "label": "first_line", "file": "utils.sh", "community": "reporting"},
    {"id": "report.sh", "label": "report.sh", "file": "report.sh", "community": "reporting"},
    {"id": "tests/test_report.sh", "label": "tests/test_report.sh", "file": "tests/test_report.sh", "community": "reporting"}
  ],
  "edges": [
    {"source": "report.sh", "target": "utils.sh:foo", "relation": "calls", "confidence": "EXTRACTED"},
    {"source": "tests/test_report.sh", "target": "report.sh", "relation": "calls", "confidence": "EXTRACTED"}
  ]
}
JSON
git add -A
git commit -qm "add graphify map"
