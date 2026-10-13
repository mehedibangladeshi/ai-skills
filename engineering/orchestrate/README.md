# orchestrate

Turns a goal into a plan: asks you questions, shows a preview for approval, then hands the work to Haiku/Sonnet sub-agents (max 3 at a time) and verifies the result.

## Install

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

## Use

Manual only. Run:

```
/orchestrate add dark mode to settings
/orchestrate resume
```

- Asks clarifying questions until the scope is locked.
- Writes a plan file and previews it; nothing is built until you approve.
- Sub-agents do the building; the orchestrator plans and checks.
- A verifier sub-agent runs the checks, then the work is closed out.
- `resume` picks an interrupted run back up.

## Requirements

- Run it on an Opus or Sonnet model (switch with `/model`); it stops on Haiku.

[Back to all skills](../../README.md)
