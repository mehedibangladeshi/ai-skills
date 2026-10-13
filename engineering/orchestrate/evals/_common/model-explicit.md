---
type: tool_used
tool: Agent
input_match: '^(?![\s\S]*"model"\s*:)'
min: 0
max: 0
---
Every Agent call sets `model` explicitly (haiku or sonnet), custom agent types included; none inherit the orchestrator's model.
