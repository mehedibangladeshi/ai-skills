# ai-skills

My [Claude Code Agent Skills](https://code.claude.com/docs/en/skills), shared in case they help you.

## Skills

### Engineering

| Skill | What it does |
|---|---|
| [orchestrate](engineering/orchestrate/README.md) | Plans a goal with you, then has cheaper sub-agents build and verify it. Manual: `/orchestrate <goal>`. |
| [git-commit](engineering/git-commit/README.md) | Drafts, checks, and makes a Conventional Commits commit, then offers to push. Manual: `/git-commit`. |
| [rn-version-upgrade](engineering/rn-version-upgrade/README.md) | Upgrades React Native across JS, Android, and iOS, one platform at a time. |

### Research

| Skill | What it does |
|---|---|
| [research-app-gaps](research/research-app-gaps/README.md) | Mines app reviews and Reddit to find unmet needs in an app niche. |
| [research-competitor-analysis](research/research-competitor-analysis/README.md) | Profiles the top competitors in a niche and suggests how to win. |

## Install

`<category>` is `engineering` or `research`; `<skill>` is the folder name.

```bash
# A: one skill, no clone
mkdir -p ~/.claude/skills/<skill>
curl -fsSL -o /tmp/<skill>.skill https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/<skill>.skill
unzip -o /tmp/<skill>.skill -d ~/.claude/skills/<skill>
# B: clone + symlink (update with git pull)
git clone https://github.com/mehedibangladeshi/ai-skills.git
mkdir -p ~/.claude/skills && ln -s "$(pwd)/ai-skills/<category>/<skill>" ~/.claude/skills/<skill>
```

Then start a new Claude Code session. Each skill's README has the exact commands.

## Adding a skill

1. Create `<category>/<name>/` with a `SKILL.md` (frontmatter: `name`, `description`) and a `README.md`.
2. Package it: `cd <category>/<name> && zip -r ../../<name>.skill . -x 'evals/*'`
3. Attach the `.skill` file to a GitHub Release.

## License

MIT, see [LICENSE](LICENSE).
