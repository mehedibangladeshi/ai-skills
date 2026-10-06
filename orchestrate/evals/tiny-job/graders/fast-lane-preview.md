---
type: llm
---
The skill has a "fast lane" for tiny jobs (≤2 tasks, each low-complexity, no security, no new domain terms): it skips the full interview and shows a short "mini preview" with only a one-line goal, a task table (columns include Task and Tier) and a "Verify with" line, then waits for approval.

PASS if the final message is such a short preview: one-line goal, a task table where every task's tier is haiku, a "Verify with" line, and it asks for approval. No long interview questions first.
FAIL if it asks several design/interview questions instead, shows a long full preview with Risks/Decisions/Mix sections padded out, assigns sonnet or "orchestrator" as a tier, or has no task table.
