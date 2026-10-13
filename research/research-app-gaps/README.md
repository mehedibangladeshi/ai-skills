# research-app-gaps

Finds unmet user needs in an app niche by mining store reviews, Product Hunt and Reddit, and writes a ranked gap report with opportunities for founders.

## Install

**One skill, no clone:**
```bash
mkdir -p ~/.claude/skills/research-app-gaps
curl -fsSL -o /tmp/research-app-gaps.skill https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/research-app-gaps.skill
unzip -o /tmp/research-app-gaps.skill -d ~/.claude/skills/research-app-gaps
```

**Or clone + symlink** (update with `git pull`):
```bash
git clone https://github.com/mehedibangladeshi/ai-skills.git
mkdir -p ~/.claude/skills && ln -s "$(pwd)/ai-skills/research/research-app-gaps" ~/.claude/skills/research-app-gaps
```

Start a new Claude Code session to load it.

## Use

Triggers automatically. Example prompts:

- `/research-app-gaps "note-taking apps"`
- `/research-app-gaps "habit tracker apps" --apps "Habitica, Streaks, Finch"`
- "What are users complaining about in budgeting apps?"

- Optional flags: `--apps` (skip discovery), `--market` (default Global).
- Finds top apps, then mines App Store/Play Store reviews, Product Hunt comments and Reddit threads.
- Prints a terminal summary of the ranked gaps.
- Writes `<niche>/<niche>-<date>.md` and `.html` in the current directory.

## Requirements

- Web search and fetch access in Claude Code.

[Back to all skills](../../README.md)
