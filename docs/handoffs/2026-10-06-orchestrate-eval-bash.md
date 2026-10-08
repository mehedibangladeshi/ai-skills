# Handoff: give the orchestrate eval sandbox Bash
Repo: `~/Documents/project/ai-skills` (branch master; skill symlinked at `~/.claude/skills/orchestrate`).

**State:** the orchestrate rewrite (P0–P3) is done but **uncommitted** — see `docs/plans/2026-10-06-orchestrate-fix-merged-audit.md` (Status Complete, full log). Commit it first (or ask the user) so eval changes land in a separate commit.

**Problem:** `orchestrate/evals/run.sh` passes `--allow-tools Edit Write` only. The comment there says the Bash sandbox refuses to run while `~/.docker` holds a symlink. As a result `no-git-writes` (`orchestrate/evals/_common/no-git-writes.md`, a `tool_used: Bash` grader) passes trivially, and EXECUTE/VERIFY behaviour is untested (`docs/audits/2026-10-06-merged.md` → "Not covered yet").

**Fact found (2026-10-06):** `~/.docker` itself is a real dir; the symlinks are inside `~/.docker/cli-plugins/` (docker-dev, docker-sandbox, docker-scout, docker-ai, … → `/Applications/Docker.app/...`). Docker Desktop manages them.

**Steps:**
1. Confirm the blocker: run one case with Bash allowed (`orchestrate/evals/run.sh --case tiny-job --runs 1 --allow-tools Edit Write Bash` or edit locally) and capture the exact sandbox error.
2. Fix is the user's call (it touches Docker Desktop's install): options — Docker Desktop setting to not install CLI plugins to `~/.docker`, move plugins via `cliPluginsExtraDirs` in `~/.docker/config.json`, or a sandbox setting that tolerates the symlinks. Ask before changing anything under `~/.docker`; back up `config.json` first.
3. In `run.sh`: add `Bash` to `--allow-tools`, delete the "No Bash grant" comment block.
4. Add the case named in the merged audit: a `history_file` case whose scripted user answers "go" after the preview, so EXECUTE/VERIFY run (check `claude plugin eval` docs for the history/multi-turn field via the `claude-code-guide` agent). Graders: builders get `model` haiku|sonnet, ≤3 live agents, no edits outside Own, no git writes.
5. Re-run the full suite; compare with baseline `orchestrate/evals/results/20261006-145137/` (feature/pre-approved/read-only/release-goal 1.0, tiny-job 0.958). Bash being allowed may surface real `no-git-writes` failures — report, don't loosen graders without the user.

**Done when:** Bash allowed in run.sh, sandbox runs, new EXECUTE case exists and passes, no regression vs baseline.

**Suggested skills:** `/orchestrate` (if splitting work), `update-config` (if a Claude Code sandbox setting is the fix), `diagnose` (sandbox error), `claude-code-guide` agent (plugin eval format), `git-commit`.
