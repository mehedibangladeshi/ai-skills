#!/usr/bin/env bash
# Nudge Claude to run the /reflect skill (doc updater) once before `git commit`
# and once per session at Stop, when non-.md files have changed.
# Registered in Claude Code settings as a `type: "command"` hook for
# PreToolUse (matcher "Bash") and Stop. Block = stderr + exit 2; else exit 0.
# Fails open: missing jq, bad JSON, or non-git cwd all exit 0.

set -u

command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
field() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

event="$(field '.hook_event_name // empty')" || exit 0
[ -n "$event" ] || exit 0
# Cheap check first: a non-commit Bash command exits before any git call.
if [ "$event" = PreToolUse ]; then
  printf '%s' "$(field '.tool_input.command // empty')" \
    | grep -qE '(^|[;&|(] *)([A-Za-z_][A-Za-z0-9_]*=[^ ]* +)*git( +(-[cC] +("[^"]*"|[^ "]+)|--[a-z-]+(=[^ ]+)?))* +commit( |$)' || exit 0
fi
cwd="$(field '.cwd // empty')"
sid="$(field '.session_id // "nosession"' | tr -c 'A-Za-z0-9_\n-' '_')"
[ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Skip unless some changed path is not *.md (rename lines: take the new path).
git -C "$cwd" status --porcelain -uall 2>/dev/null | cut -c4- | sed 's/.* -> //' \
  | grep -vqiE '\.md"?$' || exit 0

dir="${REFLECT_HOOK_DIR:-${TMPDIR:-/tmp}}"

case "$event" in
  PreToolUse)
    head="$(git -C "$cwd" rev-parse HEAD 2>/dev/null || echo nohead)"
    marker="$dir/reflect-hook-$sid-$head"
    [ -e "$marker" ] && exit 0
    mkdir -p "$dir" 2>/dev/null; : > "$marker" 2>/dev/null || exit 0
    echo "Before committing, run the /reflect skill to update docs affected by this session's changes, stage any doc updates, then retry the commit. (reflect-hook: shown once per commit)" >&2
    exit 2 ;;
  Stop)
    [ "$(field '.stop_hook_active // false')" = "true" ] && exit 0
    marker="$dir/reflect-hook-$sid-stop"
    [ -e "$marker" ] && exit 0
    mkdir -p "$dir" 2>/dev/null; : > "$marker" 2>/dev/null || exit 0
    echo "Code changed this session. Run the /reflect skill to update affected docs and report which docs changed. (reflect-hook: shown once per session)" >&2
    exit 2 ;;
esac
exit 0
