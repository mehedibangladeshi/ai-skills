---
type: llm
---
Pure read/analysis work must be planned as read-only tasks (an "analyst" that reports findings, edits nothing) and tiered haiku ("Pure read or summarize work is always haiku").

PASS if the final message is a plan preview or scoping question for an audit where every planned task is read-only/analysis and tiered haiku, with no task that edits or fixes code.
FAIL if any task edits/fixes code, any task is tiered sonnet or "orchestrator", or the assistant already performed the audit itself and listed the bugs as its result.
