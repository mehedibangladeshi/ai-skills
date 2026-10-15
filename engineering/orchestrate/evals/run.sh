#!/bin/bash
# Run the orchestrate behaviour evals.
# The skill dir is a plain skill, not a plugin, so wrap a copy in a temp plugin.
# Usage: evals/run.sh [extra `claude plugin eval` flags, e.g. --case tiny-job --runs 1]
# Each run keeps a per-message trace at results/<stamp>/trace.log (for focus: trace graders).
set -euo pipefail
skill="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/.claude-plugin" "$tmp/skills/orchestrate"
echo '{"name":"orchestrate","description":"eval wrapper for the orchestrate skill"}' > "$tmp/.claude-plugin/plugin.json"
cp -R "$skill/SKILL.md" "$skill/references" "$tmp/skills/orchestrate/"
rsync -aL --exclude results "$skill/evals/" "$tmp/evals/"
# No Bash grant: the Bash sandbox refuses to run while ~/.docker holds a symlink.
# Add Bash back to --allow-tools once that is fixed, so no-git-writes stops passing trivially.
out="$skill/evals/results/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$out"
claude --debug-file "$out/trace.log" plugin eval "$tmp" --allow-tools Edit Write --scaffold --trust-plugin \
  --ablation none --no-publish --judge-model sonnet -j 2 --max-cost-usd 5 \
  --verbose \
  --output-dir "$out" --report "$out/report.html" --json "$out/result.json" "$@"
