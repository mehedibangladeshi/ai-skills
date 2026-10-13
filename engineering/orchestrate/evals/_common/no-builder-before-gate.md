---
type: tool_used
tool: Agent
input_match: '^(?![\s\S]*"subagent_type"\s*:\s*"Explore")'
min: 0
max: 0
---
Before the Phase 3 gate only Explore scouts may run; any other Agent call (builder, analyst) means the gate was skipped. Counts nested calls from sub-agents too.
