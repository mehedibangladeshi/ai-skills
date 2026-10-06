---
type: tool_used
tool: Edit
input_match: '"file_path"\s*:\s*"[^"]*(utils\.sh|report\.sh|test_report\.sh|VERSION|CHANGELOG\.md)"'
min: 0
max: 0
---
Guardrail "You never implement": nothing edits project files before approval. Counts sub-agent calls too, so a builder launched before the gate also fails this.
