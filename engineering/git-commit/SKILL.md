---
name: git-commit
description: Draft, preview, and make a git commit (with an optional push) following Conventional Commits v1.0.0 in this user's type(scope) shape. Use when the user runs /git-commit, or directly asks to commit the current changes.
---

# Git Commit

Drives the full commit flow: gather context, draft a message, validate it, get confirmation, commit, then offer to push. Only fires on explicit `/git-commit` or a direct "commit this" request.

## Message format

Conventional Commits v1.0.0, hybrid shape:

```
<type>(<scope>)[!]: <description>      <- header, whole line <=100 chars
<blank>
[body: extra `type(scope): desc` lines for bundled concerns, and/or prose]
<blank>
[footers: `Token: value` or `Token #value`]
```

- Types: `fix`, `feat`, `chore`, `docs`, `refactor`, `test`, `perf`, `style`, `build`, `ci`, `revert`. `feat` = new user-facing capability, `fix` = bug fix.
- Scope required: noun naming the codebase area, inferred from touched files + recent log for consistency. Exempt: merge (`chore: merge <branch> into <current>`) and revert (`revert: <original header>` + footer `Refs: <sha>`).
- Bundled concerns: if unrelated, suggest splitting into separate commits first. If the user keeps one commit, the primary concern is the header, others become body lines.
- Breaking (removes/renames/changes a contract others depend on): `!` before `:` plus footer `BREAKING CHANGE: <what breaks + how to migrate>` (uppercase token exactly). Always call it out at preview.
- Footers: `Refs: <id>` only when the user supplies a ticket/issue ID — never invent one.
- Never add `Co-Authored-By` or any AI-attribution trailer (validator rejects it).

**Description-writing guidance:** each line doubles as raw material for release notes later — both technical (what changed, where) and product-facing (what a user/stakeholder would notice). Favor plain, outcome-oriented phrasing over terse jargon: state what changed *and its effect*, one sentence, no filler ("various changes", "minor fixes", "updates stuff").

Example: prefer `fix(dhakapost_source): select the span matching the timestamp pattern, fixing wrong listing times` over `fix(dhakapost_source): use regex match not first span`.

## Flow

Scripts live in `~/.claude/skills/git-commit/scripts/` — `scripts/...` below is shorthand; always invoke them by that full path (cwd is the user's repo).

1. Run `scripts/gather_context.sh`. Act on `flags`:
   - NOTHING_TO_COMMIT: tell the user, stop.
   - MERGE_IN_PROGRESS: use the merge header.
   - UNSTAGED_ONLY: you'll propose an explicit `--add` list.
   - LARGE_DIFF: sample the diff, lean on the diffstat.
   - BINARY_ONLY / DELETIONS_ONLY: infer from filenames / use "remove" phrasing.
2. Read only the diff you need: `git diff --cached` (or `git diff -- <path>` for unstaged), per-file for large diffs.
3. Analyze: what changed, where, why; bundled? breaking?
4. Write the draft to a temp file (e.g. `$TMPDIR/commit_msg.txt`).
5. `scripts/validate_commit_message.sh <file>` — nonzero exit: revise, re-run; never present a failing message. `warn:` lines: fix if reasonable, else mention.
6. Preview: the message; the files that will be committed (staged list, or the proposed `--add` list — explicit toplevel-relative paths from gather_context output, never `.`/`-A`, never untracked files the user didn't mention); any BREAKING flag; and the exact command, e.g. `scripts/commit.sh $TMPDIR/commit_msg.txt --add app/a.js app/b.js`. Ask "Commit with this message? (yes / no / edit)".
7. Handle the response:

   | User says | Action |
   |---|---|
   | yes / y / ok / lgtm / any positive gesture | run `scripts/commit.sh` (validates again, stages only the listed paths, commits with `-F`, prints the new log line) |
   | no / cancel | stop, no commit made |
   | edit / gives a correction | incorporate it, re-validate, show the revised message, ask again |
   | supplies their own message directly | validate it, use verbatim if it passes, confirm once before committing |

8. After the commit, ask about push. Yes: `scripts/commit.sh --push-only` (pushes to upstream, or `-u origin HEAD` if none). No: stop, commit stands locally.
