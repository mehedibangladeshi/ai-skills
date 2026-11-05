#!/usr/bin/env bash
# Validates a PR title and body. Errors print `error: <reason>` to stderr (exit 1);
# `warn:` lines never fail.
#
# Usage:
#   validate_pr.sh <title-file> <body-file>
#   validate_pr.sh --self-test

set -u

TITLE_RE='^(fix|feat|chore|docs|refactor|test|perf|style|build|ci|revert)(\(([^)]+)\))?(!)?: (.+)$'
ATTRIBUTION_RE='co-authored-by|generated (with|by).*claude|🤖'
MAX_LEN=100
COMMIT_VALIDATOR="$HOME/.claude/skills/git-commit/scripts/validate_commit_message.sh"

errors=0
err()  { echo "error: $1" >&2; errors=$((errors + 1)); }
warn() { echo "warn: $1" >&2; }

check_title() {
  local title="$1" lines subj
  lines="$(printf '%s\n' "$title" | grep -c .)"
  [ "$lines" -le 1 ] || { err "title must be one line ($lines lines)"; return; }
  title="$(printf '%s\n' "$title" | grep . | head -n1)"
  [ -n "$title" ] || { err "title is empty"; return; }
  [ "${#title}" -le "$MAX_LEN" ] || err "title exceeds $MAX_LEN chars (${#title})"
  case "$title" in "Merge "*|"Revert "*) return ;; esac
  if [[ "$title" =~ $TITLE_RE ]]; then
    [ -n "${BASH_REMATCH[3]}" ] || err "scope required: <type>(<scope>): <subject>: $title"
    subj="${BASH_REMATCH[5]}"
    [[ "$subj" =~ ^[[:space:]]*$ ]] && err "subject is empty: $title"
    [[ "$subj" == *. ]] && err "subject must not end with a period: $title"
  else
    err "title does not match <type>(<scope>)[!]: <subject> (types: fix feat chore docs refactor test perf style build ci revert): $title"
  fi
  if [ -x "$COMMIT_VALIDATOR" ]; then
    local out
    out="$(printf '%s\n' "$title" | "$COMMIT_VALIDATOR" 2>&1)" || err "git-commit validator rejected title: $out"
  fi
}

check_body() {
  local body="$1" n
  if [[ "$body" =~ ^[[:space:]]*$ ]]; then err "body is empty"; return; fi
  printf '%s\n' "$body" | grep -Eiq -- "$ATTRIBUTION_RE" && err "AI attribution not allowed in body"
  printf '%s\n' "$body" | grep -Fq -- '<!--' && err "leftover HTML comment (<!--): remove template guidance"
  if printf '%s\n' "$body" | grep -Eq '^## Description[[:space:]]*$'; then
    printf '%s\n' "$body" | awk '
      /^## Description[[:space:]]*$/ { in_d = 1; next }
      /^## / { in_d = 0 }
      in_d && $0 !~ /^[[:space:]]*$/ { found = 1 }
      END { exit !found }' || err "## Description section has no content"
  fi
  n="$(printf '%s\n' "$body" | wc -l | tr -d ' ')"
  [ "$n" -le 250 ] || warn "body is $n lines (>250)"
}

validate() {
  errors=0
  check_title "$1"
  check_body "$2"
  [ "$errors" -eq 0 ]
}

self_test() {
  local pass=0 fail=0 good_body a100
  a100="$(printf '%100s' '' | tr ' ' a)"
  good_body=$'## Description\n\nAdds the thing.\n\n## Testing\n\nRan it.'

  check() {
    local desc="$1" title="$2" body="$3" expect_ok="$4" ok
    if validate "$title" "$body" 2> /dev/null; then ok=true; else ok=false; fi
    if [ "$ok" = "$expect_ok" ]; then echo "PASS: $desc"; pass=$((pass + 1))
    else echo "FAIL: $desc"; fail=$((fail + 1)); fi
  }

  check "good title and body" "feat(api): add search" "$good_body" true
  check "missing scope" "feat: add search" "$good_body" false
  check "title over 100 chars" "fix(x): $a100" "$good_body" false
  check "Co-Authored-By body" "feat(api): add search" "$good_body"$'\n\nCo-Authored-By: X <x@y.z>' false
  check "leftover <!--" "feat(api): add search" $'## Description\n\n<!-- explain -->\nreal text' false
  check "plain Claude Code mention passes" "feat(api): add search" "$good_body"$'\n\nthis skill targets Claude Code' true
  check "Generated with Claude Code fails" "feat(api): add search" "$good_body"$'\n\nGenerated with Claude Code' false
  check "bare --> passes" "feat(api): add search" "$good_body"$'\n\na --> b' true
  check "<!-- x --> fails" "feat(api): add search" "$good_body"$'\n\n<!-- x -->' false
  check "empty Description" "feat(api): add search" $'## Description\n\n## Testing\n\nRan it.' false
  check "Merge title exempt" "Merge branch dev into main" "$good_body" true

  # shellcheck disable=SC2154
  echo "---"; echo "$pass passed, $fail failed"
  [ "$fail" -eq 0 ]
}

main() {
  if [ "${1:-}" = "--self-test" ]; then self_test; exit $?; fi
  if [ $# -ne 2 ] || [ ! -r "$1" ] || [ ! -r "$2" ]; then
    echo "usage: validate_pr.sh <title-file> <body-file> | --self-test" >&2
    exit 2
  fi
  validate "$(cat "$1")" "$(cat "$2")"
}

main "$@"
