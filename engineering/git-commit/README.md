# git-commit

Conventional Commits that pass a validator before they exist, and never carry an AI trailer.

## The problem

Ask a model to "commit this" and you get a message in whatever mood it was in. Sometimes `feat:`, sometimes a sentence. No scope. A `Co-Authored-By` trailer you didn't ask for. And `git add -A` swept in the scratch file you forgot about.

## What it does differently

- **A shell validator gates the message.** `scripts/validate_commit_message.sh` checks the header against `type(scope)[!]: description`, with the type from an allowed list (`fix feat chore docs refactor test perf style build ci revert`). Header is 100 characters or fewer. Line 2 is blank. A failing message is revised, never shown to you.
- **AI attribution is a hard error.** `Co-Authored-By` or `Generated ... Claude` anywhere in the message fails validation. It cannot be committed through the skill.
- **Scope is required and inferred.** It reads the touched files and recent log so scopes stay consistent. Merge (`chore: merge <branch> into <current>`) and revert are exempt.
- **It stages only what it lists.** `commit.sh --add` takes explicit paths. `.`, `-A`, `--all` and the repo root are refused. Untracked files you didn't mention stay out.
- **It reads the situation first.** `gather_context.sh` flags nothing to commit, merge in progress, unstaged-only, binary-only, deletions-only, and large diffs (over 500 changed lines), and the draft adapts to each.
- **Breaking changes are explicit.** `!` before the colon plus an uppercase `BREAKING CHANGE:` footer, called out at preview.

## Before / after

Plain prompt: "commit this" becomes `Update stuff` plus a trailer, after staging everything.

With this skill:

```
Commit with this message? (yes / no / edit)

fix(dhakapost_source): select the span matching the timestamp pattern, fixing wrong listing times

Files: dhakapost/source.py
Command: scripts/commit.sh $TMPDIR/commit_msg.txt --add dhakapost/source.py
```

You see the message, the exact files and the exact command before anything runs.

## Use

```
/git-commit
```

Or ask "commit this". It only fires on an explicit request.

1. Gathers context and the diff it needs.
2. Drafts a message and runs the validator until it passes.
3. Previews message, file list and command, then asks yes, no or edit.
4. Commits with `commit.sh`, which validates again before staging.
5. Asks whether to push. Yes runs `commit.sh --push-only`: `git push`, or `git push -u origin HEAD` if there's no upstream. No leaves the commit local.

If you bundle unrelated changes, it suggests splitting first. If you keep one commit, the main concern becomes the header and the rest become body lines. A `Refs:` footer appears only if you supply an ID. It never invents one.

The scripts carry a `--self-test` flag if you want to check them yourself.

## Install

Easiest: paste `Fetch and follow https://raw.githubusercontent.com/mehedibangladeshi/ai-skills/master/INSTALL.md` into your coding agent.

**One skill, no clone:**
```bash
mkdir -p ~/.claude/skills/git-commit
curl -fsSL -o /tmp/git-commit.skill https://github.com/mehedibangladeshi/ai-skills/releases/latest/download/git-commit.skill
unzip -o /tmp/git-commit.skill -d ~/.claude/skills/git-commit
```

**Or clone + symlink** (update with `git pull`):
```bash
git clone https://github.com/mehedibangladeshi/ai-skills.git
mkdir -p ~/.claude/skills && ln -s "$(pwd)/ai-skills/engineering/git-commit" ~/.claude/skills/git-commit
```

Start a new Claude Code session to load it.

## Requirements

- `git`, inside a git repository.
- `bash` for the scripts.

## FAQ

**Is this strict Conventional Commits?**
Mostly. It's v1.0.0 in a hybrid shape: scope is required, and the body may hold extra `type(scope): desc` lines for bundled concerns. If you want scope-less commits, this isn't your tool.

**Why no Co-Authored-By?**
That's a choice baked in, not a setting. The validator rejects it. If you want the trailer, commit another way.

**Will it push without asking?**
No. Push is a separate question after the commit. Decline and the commit stands locally.

**What if the diff is huge, or only binaries?**
Over 500 changed lines it samples the diff and leans on the diffstat. Binary-only changes get a message inferred from filenames. Deletion-only changes get "remove" phrasing.

**Can I write my own message?**
Yes. It validates yours, uses it verbatim if it passes, and confirms once before committing.

**What do the descriptions look like?**
One plain sentence on what changed and its effect, written so it can be reused in release notes. "Various changes" and "minor fixes" are on the avoid list.

[Back to all skills](../../README.md)
