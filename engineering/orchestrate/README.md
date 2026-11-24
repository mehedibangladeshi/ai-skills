# orchestrate

You plan and approve. Cheaper models build. The orchestrator never writes the code itself.

## The problem

You hand a big goal to one expensive model in one long session. It guesses at scope, edits files as it goes, reads half the repo into context, and tells you it's done. Nobody checked. If it died at step six of ten, you reconstruct the state by hand.

## What it does differently

- **It never implements.** Every task goes to a sub-agent with a tier and provider. The orchestrator plans, watches and judges. The one exception is a fix of 5 lines or fewer, once per task, for a defect found in verification.
- **Model tier comes from a score.** Each task gets 0–2 on Ambiguity, Breadth and Reasoning. A total of 0–2 goes to `light`, and 3–4 goes to `standard`. A 5–6 gets split until every piece is 4 or less. If it can't split cleanly, it runs whole on `deep`. Security builders run at `deep` on the single-provider selection or, by default, the host's provider (first available CLI on an `other` host, Claude preferred). You can ask for `deep` yourself. Data-migration work is `standard` at minimum.
- **Hard approval gate.** It shows a plan preview with tasks, tiers, providers, owned files, acceptance and verify commands, then waits for your reply. "Just go" written into your goal is ignored. "ok, but..." requests an edit.
- **Three slots by default.** Each file in a wave has exactly one owner. Contracts (shared types, names, file ownership) are fixed before anyone starts, so parallel agents don't collide.
- **Separate verification.** A light verifier runs the checks and flags changes outside the task's owned files. A standard reviewer covers non-security standard and deep diffs. A deep security reviewer checks security diffs on the other provider, or the same provider in single-provider mode. Each kind reviews its wave in one batch unless an early review leaves later diffs for a second pass.
- **Resumable.** The plan lives in `docs/plans/YYYY-MM-DD-<slug>.md` with a Status line and a launch log. If a run is interrupted, `resume` reads that file and continues.
- **Reuses a codebase map.** If it finds one (graphify, CodeGraph and similar), scouts query it before grepping. It never builds or refreshes one.

## Before / after

Plain prompt: "add dark mode to settings". One session explores, edits ten files, runs whatever it feels like, reports success.

With this skill:

```
/orchestrate add dark mode to settings
```

It asks scoping questions, in rounds (the whole frontier, numbered), with a recommended answer each. It posts a locked scope and waits. Then the preview, roughly:

```
| # | Task | Tier | Provider | Files owned | Depends on | Acceptance |
|---|------|------|----------|-------------|------------|------------|
| 1.1 | Theme tokens + context | standard → <resolved model> | codex | src/theme/* | — | Theme context exposes the active theme |
| 1.2 | Settings toggle | light → <resolved model> | claude | src/settings/Row.tsx | 1.1 | Toggle updates the active theme |
Verify with: npm test, npm run lint
Mix: 1 light · 1 standard · 0 deep · 2 waves · 1 claude / 1 codex
Approve, edit, or reject?
```

Nothing is built until you reply. (Illustrative. Your tasks will differ.)

## Use

Manual only. The model never invokes it on its own.

```
/orchestrate <goal> [--claude|--codex] [--single-provider]    # Claude Code
/orchestrate resume
$orchestrate <goal> [--claude|--codex] [--single-provider]    # Codex
$orchestrate resume
```

Phases run in order: GRILL, PLAN, PREVIEW, EXECUTE/VERIFY, CLOSE. Trivial goals (2 tasks or fewer, all low score, no security work, no new domain terms) take a fast lane and skip the grilling.

Control words, any time:

- `stop` or `pause`: launches nothing new, lets live agents finish, sets Status `Paused`.
- `resume`: picks up the newest plan in `docs/plans/` that isn't `Complete` or `Rejected`.
- `reject`: sets Status `Rejected`, lists the GLOSSARY.md and ADR edits it made, asks whether to keep or revert them.

## Install

Easiest: paste `Fetch and follow https://raw.githubusercontent.com/mehedibangladeshi/ai-skills/main/INSTALL.md` into your coding agent.

**One skill, no clone:**
```bash
mkdir -p ~/.claude/skills/orchestrate
curl -fsSL -o /tmp/orchestrate.skill https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/orchestrate.skill
unzip -o /tmp/orchestrate.skill -d ~/.claude/skills/orchestrate
```

**Or clone + symlink** (update with `git pull`):
```bash
git clone https://github.com/mehedibangladeshi/ai-skills.git
mkdir -p ~/.claude/skills && ln -s "$(pwd)/ai-skills/engineering/orchestrate" ~/.claude/skills/orchestrate
```

Start a new Claude Code session to load it.

**Codex, one skill, no clone:**
```bash
mkdir -p ~/.agents/skills/orchestrate
curl -fsSL -o /tmp/orchestrate.skill https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/orchestrate.skill
unzip -o /tmp/orchestrate.skill -d ~/.agents/skills/orchestrate
```

**Codex, or clone + symlink** (update with `git pull`):
```bash
git clone https://github.com/mehedibangladeshi/ai-skills.git
mkdir -p ~/.agents/skills && ln -s "$(pwd)/ai-skills/engineering/orchestrate" ~/.agents/skills/orchestrate
```

Start a new Codex session and invoke `$orchestrate <goal>`.

## Requirements

- Run it on a standard or deep host model. With a light model, it asks you to switch and stops.
- In Codex, run it on Sol or Astra. If you're on Luna or Terra, switch to Sol or Astra first.
- Use `python3` and an available way to delegate. The host can use native sub-agents for its provider. CLI workers need the corresponding CLI installed and authenticated. Codex CLI workers require `codex exec` with `--json`, `--output-last-message` and `--sandbox` support.
- A git repo is best. Without one it asks whether to `git init` with a baseline commit, or falls back to copying owned files to a scratchpad and diffing.

## Providers and flags

Claude and Codex share worker tasks by default when both are available. The host uses native sub-agents for its own provider when supported and launches the other provider's CLI in the background. A host without native sub-agents uses CLI workers for both providers. If it can't delegate, it stops. See [Launching](references/providers.md#launching) and [No sub-agents](references/providers.md#no-sub-agents).

- `--claude` or `--codex` selects the planner provider. If it differs from the host and is available, the selected provider's deep model runs PLAN via CLI with the lock, scout digests and the planning steps. The host keeps GRILL, PREVIEW and the approval gate. The host plans when you select its provider and for every fast-lane run. If the selected CLI is unavailable, the host plans and the preview reports the fallback.
- `--single-provider` keeps every delegated role on the selected provider, or on the host's provider when no planner flag is set (first available CLI on `other`, Claude preferred). An unavailable sole provider stops the run; a tight budget pauses it. See [Flags](references/providers.md#flags).

The [model map](references/providers.md#model-map) lists each tier's models, Codex reasoning effort and the fallback for a missing model family.

- **Budget routing.** PLAN checks eligible providers before the preview and again before each wave (`lane.py budget --only <provider>` when one remains). Only flexible builders and the standard reviewer can move. Light scouts, analysts, verifiers and fast-lane builders stay pinned. A `pause` route pauses the run. If the required security reviewer is unavailable, rate-limited or tight, its tasks pause for the user. See [Routing and budget](references/providers.md#routing-and-budget) and [Security](references/providers.md#security).
- **Slots.** PLAN groups up to five independent tasks per wave. When a wave exceeds three and the eligible providers receiving extra slots have budget headroom, the preview can offer five slots. Reply `slots 5` to opt in. Plain `go` keeps three. If an eligible provider turns tight mid-run, the next wave goes back to three. Larger waves split to fit the cap. See [Slots](references/providers.md#slots).
- **Deep tasks.** If more than two tasks are deep, the preview lists each one's reason and the budget note. It asks you to confirm deep unless only mandatory security tasks push the count over two. If you decline, the plan splits non-security deep tasks or uses standard where safe. Security tasks stay deep. See [Deep tasks](references/providers.md#deep-tasks).

Codex usage is read from `~/.codex/sessions`. To let it see your Claude usage too, have your status line script save its `rate_limits` to `~/.claude/usage.json`. In a Node status line, after parsing stdin into `input`:

```js
const rl = input.rate_limits;
if (rl?.five_hour && rl?.seven_day) require('fs').writeFileSync(
  require('path').join(require('os').homedir(), '.claude', 'usage.json'),
  JSON.stringify({ five_hour: rl.five_hour, seven_day: rl.seven_day }));
```

Without it, the Claude side shows as unknown and routing uses Codex's numbers only.

## FAQ

**Does this cost more than just prompting?**
It adds planning and a verifier pass. In return most of the building is routed to the cheaper tiers, and it picks the lower tier when unsure. I can't give you a number. Try it on one real task and look at the tier mix it reports at CLOSE.

**Why can't it write code itself? That seems dumb.**
Because the point is a planner that stays out of the weeds. Its context holds the plan, not file contents (it reads at most 2 files per phase, each 100 lines or fewer). Anything bigger goes to a scout.

**What does `resume` actually do?**
It restores the plan's allowed providers and previous drops, checks for newly unavailable providers, and continues from Status and the Log. If a task was launched but has no logged result, it inspects `git diff` on that task's files and treats it as a failed attempt.

**Will it run on a light host model?**
It stops and asks you to switch to a standard or deep model. The model change is yours to make.

**Does it commit or push?**
Not on its own. Commit, push, tag and publish need a request from you in that run, plus a confirmation. At CLOSE it suggests them. If `/git-commit` is installed, it uses that. It adds no AI attribution to commits or PRs.

**A sub-agent fails. Then what?**
A light task retries once with the error and current diff, then moves to standard. A standard task retries once, then the orchestrator logs its choice to try deep once or diagnose and re-delegate. A deep task retries once, then the orchestrator diagnoses. A cross-provider task whose retry fails moves to the host provider at the same tier before climbing if that provider is eligible for the role. Auth or rate-limit failures drop the provider. Ordinary tasks rerun at the same tier on another eligible provider, or pause if none can take the role. A security build or review that loses its required provider pauses for your decision. If re-delegation after diagnosis fails, the run pauses and reports. [Security](references/providers.md#security)

[Back to all skills](../../README.md)
