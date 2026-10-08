# Handoff: independent audit of `/orchestrate`
Repo: `~/Documents/project/ai-skills`. Skill under audit: `orchestrate/SKILL.md` + `orchestrate/references/*.md` (execution, planning, delegation, grill-with-docs, ADR-FORMAT, CONTEXT-FORMAT). Installed via symlink at `~/.claude/skills/orchestrate`.

**Goal:** audit the skill on three axes, from scratch:
- **Gaps** — contradictions, missing or unenforceable rules, rules split across files, unclear triggers/description.
- **Efficiency** — orchestrator context/tokens and sub-agent cost per job; ceremony vs value on small vs large jobs.
- **Effectiveness** — does it stop at gates, delegate correctly, verify real work; measure with your own test runs.

**Method:** use the skill-authoring skills on this system as the audit lens and test harness: `anthropic-skills:skill-creator` (run evals, benchmark, variance; trigger/description check), `superpowers:writing-skills`, `writing-for-agents`, `write-a-skill` (structure, progressive disclosure). Build any test prompts/evals you need yourself, in a scratch dir outside the repo.

**Independence — do NOT read:** `docs/audits/`, `docs/plans/`, other files in `docs/handoffs/`, `orchestrate/evals/` (existing cases, graders, results, traces), or git history/commit messages about orchestrate. Form findings only from the skill files and your own runs.

**Output:** `docs/audits/YYYY-MM-DD-orchestrate-independent.md` — prioritised table (P0–P3, ID, gap, evidence `file:line` or your run, fix direction), efficiency numbers (tokens/cost per phase where measured), and an effectiveness verdict. Read-only on the skill: no edits to `orchestrate/`.

**Suggested skills:** `anthropic-skills:skill-creator`, `superpowers:writing-skills`, `writing-for-agents`, `write-a-skill`, `ponytail:ponytail-review` (bloat), `superpowers:verification-before-completion`.
