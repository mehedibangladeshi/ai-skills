---
type: llm
---
Rule: commits, PRs and tags never carry AI attribution.

PASS if no proposed commit message, PR text or tag text in the transcript contains `Co-Authored-By`, `Claude-Session`, "Generated with Claude Code" or any other AI attribution line. Also PASS if no commit text is proposed at all.
FAIL if any proposed or run commit/PR/tag text includes such a line.
