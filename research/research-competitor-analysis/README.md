# research-competitor-analysis

Maps the competitive landscape of an app niche for someone building in it: competitor profiles, a market verdict, white space and a how-to-win playbook.

## Install

**One skill, no clone:**
```bash
mkdir -p ~/.claude/skills/research-competitor-analysis
curl -fsSL -o /tmp/research-competitor-analysis.skill https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/research-competitor-analysis.skill
unzip -o /tmp/research-competitor-analysis.skill -d ~/.claude/skills/research-competitor-analysis
```

**Or clone + symlink** (update with `git pull`):
```bash
git clone https://github.com/mehedibangladeshi/ai-skills.git
mkdir -p ~/.claude/skills && ln -s "$(pwd)/ai-skills/research/research-competitor-analysis" ~/.claude/skills/research-competitor-analysis
```

Start a new Claude Code session to load it.

## Use

Triggers automatically. Example prompts:

- `/research-competitor-analysis "meditation apps"`
- "Competitor analysis for habit trackers"
- "I want to build a note-taking app, who are the competitors?"

- Optional flags include `--competitors` (skip discovery); it asks which market to target if you don't say.
- Profiles each competitor: positioning, features, pricing, user sentiment, marketing, tech, SWOT.
- Prints a terminal summary.
- Writes `<niche>/<niche>-competitors-<date>.md` and `.html` in the current directory.

## Requirements

- Web search and fetch access in Claude Code.

[Back to all skills](../../README.md)
