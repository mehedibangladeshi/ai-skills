# send-pr

Push the branch and open the pull request, with a title and body you've already seen and approved.

## The problem

You finish a branch, then spend ten minutes on the PR. A title that doesn't match your commit convention. A body that's half the template with the `<!-- -->` guidance still in it. A `Co-Authored-By` line that rode in from a commit. And a push you started before you'd decided it was ready.

## What it does differently

- **Scripts do the mechanical work.** `scripts/gather_context.sh` reads the branch, base, commits ahead, diffstat, any existing PR and the template, and flags anything that should stop the run. It is read-only.
- **A validator gates the PR text.** `scripts/validate_pr.sh` checks the title against `type(scope): subject`, 100 characters or fewer, with a required scope. It rejects leftover `<!-- -->` guidance and AI attribution in the body. A failing draft is revised, never shown to you.
- **The model only drafts.** It writes the title and body and ticks the template boxes. `scripts/send.sh` does the validation, the push (`git push -u origin HEAD`), the `gh pr create` and prints the URL.
- **Nothing moves before you say so.** You see the title, the body and the template choices first. Nothing is pushed before `yes` or `draft`.
- **It never commits.** A dirty working tree stops the run and points you to `/git-commit`.
- **It uses your repo's template.** `.github/pull_request_template.md` and similar come first. If there is none, it falls back to the bundled template, which has Description, Related issue, Type of change, Area(s) affected, a DB migration or breaking change block with Door and Blast Radius lines, Screenshots and a Checklist.

## Before / after

Plain prompt: "open a PR" becomes a `gh pr create --fill` with whatever the commit subjects happened to say, and a template you didn't read.

With this skill:

```
Open this pull request? (yes / draft / edit / no)

Title: feat(ingest): retry source fetches on 429 with jittered backoff
Base: master  <-  feature/ingest-retry (4 commits, 3 files, +112 -18)

Body:
  ## Description
  Source fetches now retry on HTTP 429 with jittered backoff, capped at 5 attempts.
  ## Type of change
  - [x] New feature
  ...
```

You see the title, the base, the body and the checked boxes before anything runs.

## Use

```
/send-pr
```

Or ask "open a PR for this branch". It only fires on an explicit request.

1. Gathers context and stops on the flags it raises.
2. Drafts the title and body, fills in the template and runs the validator until it passes.
3. Previews the title, body and base, then asks `yes`, `draft`, `edit` or `no`.
4. `yes` pushes and opens the PR. `draft` opens it as a draft. Nothing is pushed before one of those two.
5. Prints the PR URL.

`scripts/send.sh` also takes `--draft` and `--dry-run` if you want to run it yourself.

## Install

Easiest: paste `Fetch and follow https://raw.githubusercontent.com/mehedibangladeshi/ai-skills/master/INSTALL.md` into your coding agent.

**One skill, no clone:**
```bash
mkdir -p ~/.claude/skills/send-pr
curl -fsSL -o /tmp/send-pr.skill https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/send-pr.skill
unzip -o /tmp/send-pr.skill -d ~/.claude/skills/send-pr
```

**Or clone + symlink** (update with `git pull`):
```bash
git clone https://github.com/mehedibangladeshi/ai-skills.git
mkdir -p ~/.claude/skills && ln -s "$(pwd)/ai-skills/engineering/send-pr" ~/.claude/skills/send-pr
```

Start a new Claude Code session to load it.

## Requirements

- `git`, inside a git repository, on a branch that has commits ahead of its base.
- `gh` (GitHub CLI), installed and authenticated (`gh auth status`).
- `bash` for the scripts.
- A GitHub remote. This skill does not work with GitLab, Bitbucket or other hosts.

## FAQ

**Why doesn't it commit for me?**
Committing is `/git-commit`'s job, and it has its own validator and file list. Keeping the two apart means a PR can't quietly sweep in files you didn't mean to commit. Dirty tree? Run `/git-commit` first, then come back.

**What if my repo has no PR template?**
It uses the bundled one. The bundled template is a sensible default, not your team's standard. Adding a template to a team repo is separate work, and once a `.github/pull_request_template.md` exists there, this skill uses it.

**What if a PR already exists for this branch?**
The context step flags it and the run stops there rather than opening a second one. Look at the existing PR, then decide what to do with it.

**Why GitHub only?**
It calls `gh pr create`. GitLab and Bitbucket have their own CLIs and their own PR flags, and I haven't built or tested those paths. Elsewhere, use the host's web flow.

[Back to all skills](../../README.md)
