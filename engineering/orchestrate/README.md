# orchestrate

You plan and approve. Cheaper models build. The orchestrator never writes the code itself.

## The problem

You hand a big goal to one expensive model in one long session. It guesses at scope, edits files as it goes, reads half the repo into context, and tells you it's done. Nobody checked. If it died at step six of ten, you reconstruct the state by hand.

## What it does differently

- **It never implements.** Every task goes to a `haiku` or `sonnet` sub-agent. The orchestrator plans, watches and judges. The one exception is a fix of 5 lines or fewer, once per task, for a defect found in verification.
- **Model tier comes from a score.** Each task gets 0-2 on Ambiguity, Breadth and Reasoning. Total 0-2 goes to `haiku`, 3-4 to `sonnet`. A 5-6 gets split until every piece is 4 or less. Security and data-migration work is `sonnet` at minimum.
- **Hard approval gate.** It shows a plan preview (tasks, tier, owned files, acceptance, verify commands) and stops. "Just go" written into your goal is ignored, and it says so. "ok, but..." counts as an edit request, not a yes.
- **At most 3 live sub-agents.** Each file in a wave has exactly one owner. Contracts (shared types, names, file ownership) are fixed before anyone starts, so parallel agents don't collide.
- **Separate verification.** A haiku verifier runs the checks and flags any path changed outside its task's owned files. A fresh sonnet reviewer reads the diffs for sonnet-tier and security-sensitive tasks.
- **Resumable.** The plan lives in `docs/plans/YYYY-MM-DD-<slug>.md` with a Status line and a launch log. If a run is interrupted, `resume` reads that file and continues.
- **Reuses a codebase map.** If it finds one (graphify, CodeGraph and similar), scouts query it before grepping. It never builds or refreshes one.

## Before / after

Plain prompt: "add dark mode to settings". One session explores, edits ten files, runs whatever it feels like, reports success.

With this skill:

```
/orchestrate add dark mode to settings
```

It asks scoping questions, one at a time, with a recommended answer each. It posts a locked scope and waits. Then the preview, roughly:

```
| # | Task                       | Tier   | Files owned          | Depends on |
| 1.1 | Theme tokens + context   | sonnet | src/theme/*          | -          |
| 1.2 | Settings toggle          | haiku  | src/settings/Row.tsx | 1.1        |
Verify with: npm test, npm run lint
Approve, edit, or reject?
```

Nothing is built until you reply. (Illustrative. Your tasks will differ.)

## Use

Manual only. The model never invokes it on its own.

```
/orchestrate <goal>
/orchestrate resume
```

Phases run in order: GRILL, PLAN, PREVIEW, EXECUTE/VERIFY, CLOSE. Trivial goals (2 tasks or fewer, all low score, no security work, no new domain terms) take a fast lane and skip the grilling.

Control words, any time:

- `stop` or `pause`: launches nothing new, lets live agents finish, sets Status `Paused`.
- `resume`: picks up the newest plan in `docs/plans/` that isn't `Complete` or `Rejected`.
- `reject`: sets Status `Rejected`, lists the CONTEXT.md and ADR edits it made, asks whether to keep or revert them.

## Install

Easiest: paste `Fetch and follow https://raw.githubusercontent.com/mehedibangladeshi/ai-skills/master/INSTALL.md` into your coding agent.

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

## Requirements

- Run it on an Opus or Sonnet model (switch with `/model`). On Haiku it says so and stops until you switch or tell it to continue.
- A git repo is best. Without one it asks whether to `git init` with a baseline commit, or falls back to copying owned files to a scratchpad and diffing.

## FAQ

**Does this cost more than just prompting?**
It adds planning and a verifier pass. In return most of the building is routed to the cheaper tiers, and it picks the lower tier when unsure. I can't give you a number. Try it on one real task and look at the tier mix it reports at CLOSE.

**Why can't it write code itself? That seems dumb.**
Because the point is a planner that stays out of the weeds. Its context holds the plan, not file contents (it reads at most 2 files per phase, each 100 lines or fewer). Anything bigger goes to a scout.

**What does `resume` actually do?**
Re-reads the plan file and continues from Status and the Log. If a task was launched but has no logged result, it inspects `git diff` on that task's files and treats it as a failed attempt.

**Will it run on Haiku?**
No. It stops and asks you to switch with `/model`. It never changes the model for you.

**Does it commit or push?**
Not on its own. Commit, push, tag and publish need a request from you in that run, plus a confirmation. At CLOSE it suggests them. If `/git-commit` is installed, it uses that. It adds no AI attribution to commits or PRs.

**A sub-agent fails. Then what?**
Haiku retries once with the error and current diff, then moves to sonnet. Sonnet retries once, then the orchestrator diagnoses and re-delegates. If that also fails, it pauses and reports.

[Back to all skills](../../README.md)
