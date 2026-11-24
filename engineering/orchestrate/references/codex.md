# Codex lane

Optional. Lets OpenAI Codex CLI (`codex exec`) build and review tasks next to Claude sub-agents, and spreads work across both subscriptions' 5-hour and weekly limits. Read this file only when the lane is requested.

`lane.py` = `python3 <this skill's dir>/scripts/lane.py`.

## Turning it on

Requested when the goal contains `--codex` or asks for Codex. Then, at the start of GRILL before any question (and again on `resume`), run:

```
command -v codex && codex exec --help | grep -cE -- '--json|--output-last-message|--sandbox'
```

On if `codex` exists and the count is 3. Otherwise, or if Bash is denied, the lane is off: put `Codex lane unavailable: <reason>` in the preview and plan Claude-only. Never assume Codex works.

Plan file header line under Status: `Codex lane: on | off (<reason>)`. `resume` reads it instead of `--codex`, re-runs the check, and logs a switch to off.

Not requested: ignore this file. No Executor column, no Codex mention, no `codex` commands.

## Executor

**Tier** (haiku/sonnet/opus) still comes from the score in `planning.md`. **Executor** (`claude` | `codex`) is a separate column: who runs the task.

- `codex` by default for builder tasks, and for the non-security reviewer.
- Always `claude`: scouts, verifiers, analysts, fast lane, every security-surface task and its reviewer, tasks that need Claude-only tools (MCP, skills, AskUserQuestion), and Codex-unavailable runs.

Model per codex task: `lane.py model <tier>` prints the flags (haiku → luna/low, sonnet → sol/medium, opus → astra/high; newest model of that family on the user's account, else only the effort). The preview's Tier cell shows the pick: `sonnet → gpt-6.2-sol`. **Mix** adds `· <n> codex`.

## Budget

Before each wave run `lane.py budget`. Log its `route:` line in the plan Log.

| route | next wave |
|---|---|
| `default` | executors as planned |
| `claude` | Codex is tight: move codex rows to claude, opus-tier rows first |
| `codex` | Claude is tight: move claude builder rows to codex, except the always-claude ones above |
| `pause` | both tight: launch nothing, Status `Paused`, report both reset times |

A side is tight at 5h ≥ 80%, or weekly used% > elapsed-week% + 10. A side reads `unknown` when its usage can't be read (Claude needs `~/.claude/usage.json`, see README); it never counts as tight. Users may set other thresholds in the goal; record them in the plan and apply them to `lane.py budget`'s numbers yourself.

Moving a row changes only its Executor. Tier, Own and acceptance stay; log the move.

## Launching a codex task

Write the brief (same template as a Claude builder, `ROLE: <tier> implementer (codex) …`, Shared allowlist included) to `<scratchpad>/<task>.brief`, then one Bash call with `run_in_background: true`:

```
codex exec -s workspace-write <lane.py model flags> --json -o <scratchpad>/<task>.md - < <scratchpad>/<task>.brief > <scratchpad>/<task>.jsonl 2>&1
```

- It takes a slot like any sub-agent. Log `<task> codex <model> bg-id`.
- Never `--dangerously-bypass-approvals-and-sandbox`, never `danger-full-access`. Tasks needing network (installs) go to a claude builder.
- When it exits, read only `<task>.md` (its REPORT). Don't read the `.jsonl` except `tail -n 5` on a non-zero exit.
- Same tree, same Own rules: the verifier catches any change outside Own, as for Claude builders.

**Codex reviewer** (non-security sonnet/opus tasks): the `## Reviewer brief` with `ROLE: codex reviewer`, run as `codex exec -s read-only <lane.py model sonnet flags> -o <scratchpad>/review-w<n>.md - < <brief>` in the background.

## Failures

```
codex ✗ → retry once on codex (Retry brief) → same tier on claude → that tier's ladder in execution.md
```

Rate-limit or auth errors (`usage limit`, `rate limit`, `401`, `login` in the jsonl tail) aren't task failures: lane off for the rest of the run, log it, rerun the task on claude at the same tier without counting a retry.
