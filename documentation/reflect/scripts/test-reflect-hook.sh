#!/usr/bin/env bash
# Self-test for reflect-hook.sh. Usage: bash test-reflect-hook.sh
set -u
HOOK="$(cd "$(dirname "$0")" && pwd)/reflect-hook.sh"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export REFLECT_HOOK_DIR="$T/markers"; mkdir -p "$REFLECT_HOOK_DIR"
fails=0

mkrepo() { # $1 = name
  local r="$T/$1"; mkdir -p "$r"
  git -C "$r" init -q && git -C "$r" config user.name t && git -C "$r" config user.email t@t
  echo a > "$r/a.sh"; echo d > "$r/d.md"
  git -C "$r" add . && git -C "$r" commit -qm init
  echo "$r"
}
run() { printf '%s' "$1" | bash "$HOOK" >/dev/null 2>&1; echo $?; }
pre() { printf '{"session_id":"%s","hook_event_name":"PreToolUse","cwd":"%s","tool_input":{"command":"%s"}}' "$1" "$2" "$3"; }
stop() { printf '{"session_id":"%s","hook_event_name":"Stop","cwd":"%s","stop_hook_active":%s}' "$1" "$2" "${3:-false}"; }
check() { # name expected actual
  if [ "$2" = "$3" ]; then echo "PASS $1"; else echo "FAIL $1 (want $2, got $3)"; fails=$((fails+1)); fi
}

R="$(mkrepo r1)"; echo b >> "$R/a.sh"
check "1a commit blocks first time" 2 "$(run "$(pre s1 "$R" 'git commit -m x')")"
check "1b commit allows second time" 0 "$(run "$(pre s1 "$R" 'git commit -m x')")"
git -C "$R" commit -qam two; echo c >> "$R/a.sh"
check "2 new HEAD blocks again" 2 "$(run "$(pre s1 "$R" 'git commit -m x')")"

R3="$(mkrepo r3)"; echo m >> "$R3/d.md"
check "3 md-only allows" 0 "$(run "$(pre s3 "$R3" 'git commit -m x')")"
check "4 non-commit command allows" 0 "$(run "$(pre s4 "$R" 'ls')")"
check "5 non-git cwd allows" 0 "$(run "$(pre s5 "$T" 'git commit -m x')")"

check "6a stop blocks first time" 2 "$(run "$(stop s6 "$R")")"
check "6b stop allows second time" 0 "$(run "$(stop s6 "$R")")"
check "7 stop_hook_active allows" 0 "$(run "$(stop s7 "$R" true)")"
check "8 malformed JSON allows" 0 "$(run 'not json{')"

[ "$fails" -eq 0 ]
