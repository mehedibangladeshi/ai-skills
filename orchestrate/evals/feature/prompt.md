---
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, AskUserQuestion, TodoWrite, Edit, Write, Bash]
---

/orchestrate add pluggable output formats to report.sh (text, json, csv), selectable by a --format flag or a REPORT_FORMAT env var, with the formatters shared via utils.sh, and cover it all in tests
