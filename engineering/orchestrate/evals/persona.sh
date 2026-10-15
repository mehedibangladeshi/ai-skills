#!/bin/bash
# Non-blind Persona runs of the codebase-map tasks via the Bench runner.
# Costs real model runs.
# Usage: evals/persona.sh [extra run.py flags]
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
python3 "$here/../../../bench/orchestrate-blind/run.py" --task-dir "$here/persona" --tasks codebase-map,codebase-map-none --arms A --runs 1 --max-turns 10 --out "$here/results/persona-$(date +%Y%m%d-%H%M%S)" "$@"
