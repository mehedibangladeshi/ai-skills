---
name: send-pr
description: Use when the user runs /send-pr, or directly asks to open, send or create a pull request.
---

# Send PR

Scripts do the mechanics; you draft the title and body and check template boxes. Invoke scripts by full path `~/.claude/skills/send-pr/scripts/<name>` (cwd is the user's repo).

Hard rules: never commit, never force-push, never add `Co-Authored-By` or any AI attribution / "Generated with" line to the title or body. Nothing is pushed before the user says yes or draft.

## Flow

1. Run `gather_context.sh`. Act on `flags`, stopping where noted. When several stop flags are present, report all of them in one message:
   - DIRTY_TREE: tell the user to run /git-commit first, stop.
   - ON_DEFAULT_BRANCH / NO_COMMITS_AHEAD: say so, stop.
   - PR_EXISTS: show the URL, stop.
   - GH_MISSING: tell the user to install `gh`, stop. GH_UNAUTH: tell the user to run `gh auth login`, stop.
   - NO_ORIGIN: stop, tell the user to add a remote with `git remote add origin <url>`.
   - LARGE_DIFF: proceed, summarize at module level.
2. Template (`template` section): a path, read and fill it. `MULTIPLE <dir>`, ask which file. `BUNDLED <path>`, use it. The bundled template is generic; a repo's own template always wins.
3. Draft from `commits`, `diffstat`, `types`, `areas`, `issues` and `breaking`; read the diff only for files that need it. `types` and `areas` cover committed history only, which is why DIRTY_TREE stops the flow: commit first so the draft sees every change.
   - Title: Conventional Commits `type(scope): subject`, scope required, header <=100 chars. Breaking change: `!` before `:` plus a `BREAKING CHANGE: <what breaks + migration>` line in the body. Exactly one commit ahead: reuse that commit's header.
   - Body: keep every template section in order, and delete every `<!-- -->` guidance comment. Fill each section:
     - Description: bullets, one change per line, fragments, no filler. Add a tiny diagram, call tree or file tree only when it explains faster than bullets.
     - Related issues: one line per `issues` entry; `None` when `none`.
     - Type of change: tick the type of the PR title; tick more types only when `types` lists them.
     - Areas affected: one checked line per `areas` entry, each with a short clause on what changed there.
     - Breaking changes: when `breaking` is `yes` or the diff changes a public contract, tick the box and write what breaks and the migration on the lines after it. Otherwise leave the box unticked and write `None` on the line right after the checkbox. Either way, fill **Door** and **Blast radius**. **Door** is one-way (hard to undo: migration, contract change) or two-way (revert is safe; `two-way` when nothing breaks). **Blast radius** is who or what breaks if it goes wrong; when nothing breaks, a short clause naming what is untouched (e.g. "none; new skill, no existing consumer touched").
     - Screenshots: only for UI changes; otherwise leave empty.
     - Reviewer checklist: keep the template's items as written, unchecked.
     - A repo template: apply the same rules to its own sections.
   - Write title and body to temp files (`mktemp`).
4. Run `validate_pr.sh <title-file> <body-file>`. On `error:` lines, fix and rerun until it exits 0.
5. Preview: `base ← branch`, the title, the full body, and the exact command. Get the command from `send.sh --base <base> --title-file <t> --body-file <b> --dry-run`, which validates and prints the push and gh commands without running them; show that output verbatim, do not compose it. Ask "Open PR? (yes / draft / edit / no)".

   | User says | Action |
   |---|---|
   | yes / ok / lgtm | run `send.sh --base <base> --title-file <t> --body-file <b>` |
   | draft | same with `--draft` |
   | edit / a correction | revise, rerun `validate_pr.sh`, re-preview, ask again |
   | no / cancel | stop, nothing pushed |

6. After `send.sh` (validates, runs `git push -u origin HEAD`, then `gh pr create`), print the PR URL it outputs last. If it exits non-zero, show its stderr and stop. If the error comes after the push line, say the branch may already be pushed.
