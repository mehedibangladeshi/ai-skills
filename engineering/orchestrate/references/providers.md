# Providers

How the orchestrator runs on Claude Code or Codex and uses both providers' workers. Tiers (`light|standard|deep`) come from `planning.md`; this file maps them to models and launches them.

`lane.py` = `python3 -I <skill dir>/scripts/lane.py`.

## Host detection

Run `lane.py host` once at start (and on `resume`): `CODEX_THREAD_ID` set → `codex`; else `CLAUDE_CODE_ENTRYPOINT` or `CLAUDECODE` set → `claude`; else `other`. Codex is checked first because nested processes inherit the parent's vars.

- Codex reads only `name` and `description` from `SKILL.md` frontmatter. The policy in `agents/openai.yaml` sets `allow_implicit_invocation: false`. Invoke explicitly with `$orchestrate <goal>` or select it from `/skills`.
- Orchestrator = the host model. A light-tier host (see `## Model map`) → ask the user to switch to a standard or deep model, then STOP.
- The host's own provider is always available natively. At GRILL start and on resume, use `lane.py available` for the other provider's CLI. If the host lacks native sub-agents, check the CLIs for all workers. Drop any provider that needs a CLI reported as unavailable.
- `other` host: no native sub-agents, see `## No sub-agents`. The available CLIs are the providers.
- The eligible providers are those allowed by the run (`## Flags`), available, and not dropped during the run. Use only these for worker routing, fallbacks, budget checks and slots. For a dropped provider, show `<provider> unavailable: <reason>` in the preview.
- Record the run's allowed providers in the plan and log every drop with its reason. On resume, restore the allowed providers and drop log first. The availability check may add drops only.
- After the fast-lane decision, record the actual planner and eligible workers under Status: `Host: <claude|codex|other> · Planner: <claude|codex|host> · Providers: claude+codex | <one>`. Use `Planner: host` when an `other` host plans locally.

## Model map

| tier | claude | codex | codex effort |
|---|---|---|---|
| light | haiku | luna (terra for visual, screenshot or browser light tasks) | low |
| standard | sonnet | sol | medium |
| deep | opus | astra | high |

- Codex slug = newest listed model of the family in `~/.codex/models_cache.json`. `lane.py model` prints the model and effort flags; if the family is missing, it prints only the effort flag.
- The preview's Tier cell shows the model, the Provider column the provider: Tier `standard → gpt-6.2-sol`, Provider `codex`.

## Launching

Use both eligible providers by default. Same provider as host → native sub-agent. Other provider → CLI in the background. Write the brief (`delegation.md` template, Shared allowlist included) to `<scratch>/<task>.brief`.

For CLI workers, always inline the flags as `$(python3 -I <skill dir>/scripts/lane.py model <provider> <tier> [--visual])`. Never store them in a variable first (zsh does not word-split unquoted variables). Codex light visual tasks add `--visual`.

**Claude host, claude worker.** Agent tool, `model` from `lane.py model claude <tier>`. `subagent_type` `Explore` for scouts, `general-purpose` for everything else. Up to N Agent calls in one message run in parallel; results arrive as notifications.

**Codex host, codex worker.** Resolve the model slug and effort with `lane.py model codex <tier> [--visual]`. Call `spawn_agent` with a `task_name` containing only lowercase letters, digits and underscores (for example `task_1_2`), the full brief as `message`, and `fork_turns: "none"` for fresh context. Pass the slug as `model` and the effort as `reasoning_effort`. If only effort resolves, omit `model`.

- Log the returned agent ID with the task. Use `wait_agent` for completion updates and collect each agent's final REPORT from its completion notification. If the wait times out before all expected reports arrive, wait again while agents are live. Use `list_agents` to check their status if needed.
- The current run's slot cap is the maximum live agent count across native and CLI workers (see `## Slots`). If Codex offers fewer native slots, respect that limit too. Wait for a slot before launching another worker.

**Claude host, codex worker.** Bash with `run_in_background: true`. Builder example:

```
codex exec -s workspace-write $(python3 -I <skill dir>/scripts/lane.py model codex standard) --json -o <scratch>/<task>.md - < <scratch>/<task>.brief > <scratch>/<task>.jsonl 2>&1
```

Light visual task: `... lane.py model codex light --visual)`.

- Builders and verifiers use `-s workspace-write` to run checks; forbid edits in verifier briefs. Scouts, analysts and reviewers use `-s read-only`. For reviewers omit `--json`. Outside a git repo add `--skip-git-repo-check`.
- Never `--dangerously-bypass-approvals-and-sandbox`, never `danger-full-access`.
- The codex sandbox has no network: tasks needing network (installs, `gh`, fetches) require an eligible claude worker. Pause and report if the assigned role cannot run there.

**Codex host, claude worker.** Background shell; `cd` into the repo first (no `--cwd`; extra dirs via `--add-dir`). `claude -p` needs network; without network access in a Codex sandbox, count claude as unavailable, drop it, and show `claude unavailable: no network in Codex sandbox` in the preview. Enable it by allowing network for the sandbox (`sandbox_workspace_write.network_access = true`) or approving the escalation. Builder example:

```
claude -p $(python3 -I <skill dir>/scripts/lane.py model claude standard) --output-format json --permission-mode acceptEdits --allowedTools "Read,Edit,Write,Glob,Grep,Bash" < <scratch>/<task>.brief > <scratch>/<task>.json
```

- Builders and verifiers use `--permission-mode acceptEdits`; forbid edits in verifier briefs. Scouts, analysts and reviewers use `--permission-mode plan` with `--allowedTools "Read,Glob,Grep,Bash"`.
- Read only the final `result` field of the JSON.

**All CLI workers:**
- Take a slot like any sub-agent. Log `<task> <provider> <model> bg-id`.
- Read only the worker's REPORT (`-o` file / `result` field). Logs only on non-zero exit: `tail -n 5`.
- Same tree, same Own rules: the verifier catches changes outside Own.
- Reviewers: use the matching `## Reviewer brief` or `## Security reviewer brief`.
- Light roles (scouts, analysts, verifiers, fast-lane builders) run on the host's provider natively. With `--single-provider` naming the other provider they run there via CLI; on an `other` host use any eligible CLI.
- Tasks needing host-only tools (MCP, skills, AskUserQuestion) require an eligible host provider; otherwise pause and report.

**Failures.** On either provider's rate-limit or auth error, drop it for the run and log why. For a security build or review, apply `## Security`. Otherwise rerun on another eligible provider at the same tier without counting a retry. If none can take the role, pause and report. Other failures follow `execution.md`'s ladder.

## Flags

- `--claude` / `--codex`: select the planner. Same as host → no-op. Different → the PLAN step (task split, contracts, tiers) runs as ONE CLI call to that provider's deep model. Input: the lock + scout digests + `planning.md` `## Steps` (rules, not transcript). With zero questions, use the drafted lock and show it atop the preview. Output: the waves table + contracts. The host shows it in the preview and keeps grill, preview, gate, dispatch and verify. Fast lane never hands off: the host plans.
- `--single-provider`: every worker on the flag's provider (`--claude`/`--codex`), else the host's (on `other`, first available CLI, claude preferred). If the sole provider is unavailable, stop and report.
- Otherwise, if the selected planner CLI is unavailable, the host plans. Note the fallback and reason in the preview. Workers use the remaining eligible providers.

## Routing and budget

Check only eligible providers once in PLAN before the preview (for Parallel/Deep) and again before each wave. With two, run `lane.py budget`; with one, run `lane.py budget --only <provider>` (routes: `default` or `pause`). With none, pause and report. Log the route.

| route | next wave |
|---|---|
| `default` | keep eligible assignments |
| `claude` | codex is tight: move flexible builders and the standard reviewer to claude, deep builders first |
| `codex` | claude is tight: move flexible builders and the standard reviewer to codex, deep builders first |
| `pause` | eligible providers tight: launch nothing, Status `Paused`, report their reset times |

- Immediately before every launch, re-check the row's provider is eligible, even on `default`. If ineligible, apply the same-tier fallback in `## Launching` or the security pause in `## Security`.
- Budget never moves light scouts, analysts, verifiers or fast-lane builders. If their provider's route is `pause`, pause the run. Preserve security pairing (`## Security`) and network or host-only tool requirements.
- Tight = 5h ≥ 80%, or weekly used% > elapsed-week% + 10. `unknown` (usage unreadable) never counts as tight. User thresholds in the goal: record in the plan and apply to the numbers yourself.
- Moving a row changes only its provider (and model per `## Model map`). Tier, Own and acceptance stay; log the move.

## Security

Tasks on the [security surface](planning.md#steps) are always deep.

- Build at deep on the run's primary provider: the selected provider for a single-provider run, otherwise the host's provider (on `other`, first available CLI at setup, claude preferred). If the primary drops before the build finishes, mark the task `Paused` and report it. Only the user may approve building at deep on a remaining eligible provider.
- Pair the actual build provider with a different eligible provider for deep review (`## Security reviewer brief`).
- Single-provider run: reviewer is the same provider, deep.
- Outside single-provider mode, if no other provider is eligible or the reviewer is dropped, rate-limited or tight, mark that task `Paused` and report it. Only the user may approve a same-provider deep review.
- Generic retry and budget moves never override these security assignments.
- Standard and security reviewers may share a wave. Batch each kind once unless early review leaves later diffs to cover (see `execution.md`).

## Slots

- PLAN groups up to 5 independent tasks per wave. Default execution cap: 3 live agents of all kinds, across both providers.
- Preview offers up to 5 only if some wave has more than 3 independent tasks, the eligible provider receiving the extra slots isn't tight, and the route isn't `pause`. User opts in with `slots 5`; plain `go` keeps 3.
- An eligible provider turns tight mid-run → 3 slots from the next wave; log it. Split any planned wave larger than the current cap before executing it.

## Deep tasks

- More than 2 deep rows: show every deep row's reason and the budget note. Ask for specific confirmation unless only mandatory security rows push the count over 2.
- No → split non-security deep rows or use standard where safe. Security rows always stay deep.

## No sub-agents

- Host has no native sub-agents (or `other`): run all workers via CLI per `## Launching`.
- Host has no native sub-agents and no eligible worker CLI: STOP and report "can't delegate". Never implement the tasks yourself.
