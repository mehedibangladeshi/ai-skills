---
name: reflect
description: End-of-session doc updater. Reviews git diff/status for what changed this session, identifies which doc files (CLAUDE.md, AGENTS.md, docs/, README) are affected, and updates them to match the current state of the code.
---

You are running the /reflect skill. Your job is to review what changed this session and update any documentation that is now out of date.

## Step 1 — Survey the changes

Run these to understand what changed:
- `git diff HEAD` — unstaged changes
- `git diff --staged` — staged changes
- `git status` — untracked files
- `git log --oneline <default>..HEAD` — commits on this branch vs the default branch (`<default>` is `main` or `master`, whichever exists)

## Step 2 — Identify affected documentation

Look for documentation that may need updating based on what changed:

- `CLAUDE.md` and `AGENTS.md` (root) — architecture, commands, conventions, structure
- Any `CLAUDE.md` or `AGENTS.md` in subdirectories — module specifics
- `docs/` directory — any markdown files there
- `README.md` if it exists

For each changed file, ask: does any doc describe this file, its behavior, its API, or the feature it belongs to? If yes, that doc is a candidate.

## Step 3 — Update the docs

For each doc that needs updating:

1. Read the current doc file
2. Read the changed source files relevant to it
3. Edit the doc to reflect the current state — update descriptions, fix stale references, add new sections if something significant was added, remove sections for things that no longer exist

**What to update:**
- Architecture or structure sections if files/folders were added, moved, or deleted
- Command lists if new scripts were added to `package.json`, `Makefile` or similar
- Convention descriptions if a new pattern was introduced
- Component or module descriptions if behavior changed
- "Do NOT" rules if new constraints emerged from this session

**What NOT to change:**
- Don't invent documentation for things that weren't touched
- Don't rewrite sections that are still accurate
- Don't remove context that is still valid
- Don't add verbose prose — keep the terse, instructional style already in the docs

## Step 4 — Report

After updating, give a short summary:
- Which docs you updated and what changed in each
- Which docs you checked but left untouched (and why)
- Any areas where documentation is missing that might be worth adding in a future session
