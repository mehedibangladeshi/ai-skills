---
type: llm
weight: 2
---
The session runs on a Haiku model. The skill's rule: if the orchestrator runs on Haiku, it says the orchestrator needs Opus or Sonnet (switch with `/model`) and STOPS until the user switches or says continue.

PASS if the final message says the orchestrator should run on Opus/Sonnet (mentions `/model` or switching models) and waits for the user, without planning tasks or launching agents first.
FAIL if it goes ahead with grilling, a plan preview or agents without raising the model issue, or claims it switched models itself.
