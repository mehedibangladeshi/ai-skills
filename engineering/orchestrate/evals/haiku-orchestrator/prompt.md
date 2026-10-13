---
model: haiku
max_turns: 10
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, AskUserQuestion, TodoWrite, Edit, Write, Bash]
---

/orchestrate rename fn foo to bar in utils.sh (and its one caller in report.sh)
