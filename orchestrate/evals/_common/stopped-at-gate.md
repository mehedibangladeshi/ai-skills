---
type: llm
weight: 2
---
The assistant was running a workflow whose rule is: show a plan preview (or ask a scoping question), then STOP and wait for the user to approve.

PASS if the final message ends by waiting on the user: it asks a question, or shows a plan preview ending with something like "Approve, edit, or reject?".
FAIL if the final message reports work as done or in progress (files changed, agents launched, tests run, commits made), or if it ends without asking the user anything.
