# ai-skills

A collection of [Claude Code Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) I use day to day, shared here in case they're useful to others.

Each skill is a self-contained directory with a `SKILL.md` (the instructions Claude reads) plus any supporting scripts/templates it needs.

## Skills

| Skill | What it does |
|---|---|
| [`rn-version-upgrade`](rn-version-upgrade) | Orchestrates a React Native version upgrade (JS, Android, iOS) using the official Upgrade Helper diff, library compatibility research, and iterative build verification. |
| [`research-app-gaps`](research-app-gaps) | Mines App Store/Play Store reviews, Product Hunt comments, and Reddit threads to surface unmet user needs in an app niche, ranked as a gap report. |
| [`research-competitor-analysis`](research-competitor-analysis) | Profiles the top competitors in an app/software niche (positioning, pricing, sentiment, GTM, SWOT) and synthesizes a market verdict and "how to win" playbook. |
| [`orchestrate`](orchestrate) | Grills a plan against your docs, previews it for approval, then delegates the build to Haiku/Sonnet sub-agents (max 3 live) with tiered verification. Manual only: `/orchestrate <goal>`. |
| [`git-commit`](git-commit) | Drafts, validates, previews, and makes a Conventional Commits v1.0.0 commit (`type(scope): desc`), with bundled self-tested scripts, then offers to push. Manual only: `/git-commit`. |

## Install

### All skills (clone the repo)

```bash
git clone https://github.com/mehedibangladeshi/ai-skills.git
ln -s "$(pwd)/ai-skills/rn-version-upgrade" ~/.claude/skills/rn-version-upgrade
ln -s "$(pwd)/ai-skills/research-app-gaps" ~/.claude/skills/research-app-gaps
ln -s "$(pwd)/ai-skills/research-competitor-analysis" ~/.claude/skills/research-competitor-analysis
ln -s "$(pwd)/ai-skills/orchestrate" ~/.claude/skills/orchestrate
ln -s "$(pwd)/ai-skills/git-commit" ~/.claude/skills/git-commit
```

### A single skill (no cloning required)

Grab the packaged `.skill` file for just the one you want from the [latest release](../../releases/latest), then:

```bash
mkdir -p ~/.claude/skills/<skill-name>
unzip <skill-name>.skill -d ~/.claude/skills/<skill-name>
```

Restart Claude Code (or start a new session) and the skill will be picked up automatically.

## Adding a new skill

1. Create a new directory at the repo root with a `SKILL.md` (frontmatter: `name`, `description`) plus any supporting files.
2. Package it: `cd <skill-name> && zip -r ../<skill-name>.skill .`
3. Attach the `.skill` file to a GitHub Release.
