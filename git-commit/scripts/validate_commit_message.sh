#!/usr/bin/env bash
# Validates a commit message (Conventional Commits 1.0.0, hybrid): header, optional
# body (prose and/or extra `type(scope): desc` lines), optional footers. Flags
# AI-attribution. Prints `line N: ...` errors and `warn: line N: ...` warnings;
# exit 1 if any error, else 0.
#
# Usage:
#   validate_commit_message.sh <file>     # read message from file
#   validate_commit_message.sh            # read message from stdin
#   validate_commit_message.sh --self-test

set -u

HEADER_RE='^(fix|feat|chore|docs|refactor|test|perf|style|build|ci|revert)(\([^)]+\))?(!)?: (.+)$'
HEADER_ATTEMPT_RE='^[a-z]+(\([^)]*\))?!?: '
FOOTER_RE='^([A-Za-z0-9-]+|BREAKING CHANGE)(: | #).+'
ATTRIBUTION_RE='Co-Authored-By|Generated.*Claude'
MAX_LEN=100

# err/warn bump `errors` in validate()'s scope (bash dynamic scoping).
err()  { echo "line $1: $2"; errors=$((errors + 1)); }
warn() { echo "warn: line $1: $2"; }
is_blank() { [[ "$1" =~ ^[[:space:]]*$ ]]; }

# check_header <line> <lineno> -> sets HDR_BANG ("!" or "")
check_header() {
  local line="$1" ln="$2"
  HDR_BANG=""
  if [[ "$line" =~ $HEADER_RE ]]; then
    local type="${BASH_REMATCH[1]}" scope="${BASH_REMATCH[2]}" desc="${BASH_REMATCH[4]}"
    HDR_BANG="${BASH_REMATCH[3]}"
    if [ -z "$scope" ] && [ "$type" != "revert" ] && [[ "$desc" != "merge "* ]]; then
      err "$ln" "scope required: <type>(<scope>): <desc>: $line"
    fi
  else
    err "$ln" "does not match <type>(<scope>)[!]: <desc> (types: fix feat chore docs refactor test perf style build ci revert): $line"
  fi
}

validate() {
  local msg="$1" errors=0 lineno=0 line i n b start fstart=0 breaking=""
  local T=() N=()

  while IFS= read -r line; do
    lineno=$((lineno + 1))
    case "$line" in \#*) continue ;; esac
    T+=("$line")
    N+=("$lineno")
  done <<< "$msg"

  n=${#T[@]}
  while [ "$n" -gt 0 ] && is_blank "${T[$((n - 1))]}"; do n=$((n - 1)); done
  if [ "$n" -eq 0 ]; then
    echo "line 1: empty commit message"
    return 1
  fi

  # Header
  check_header "${T[0]}" "${N[0]}"
  local bang="$HDR_BANG"
  if [ "${#T[0]}" -gt "$MAX_LEN" ]; then
    err "${N[0]}" "header exceeds $MAX_LEN chars (${#T[0]})"
  fi
  if [ "$n" -gt 1 ] && ! is_blank "${T[1]}"; then
    err "${N[1]}" "line 2 must be blank (header, blank line, then body)"
  fi

  # Footer paragraph: trailing paragraph (not the header's) where every line is a footer
  b=-1
  for ((i = 1; i < n; i++)); do is_blank "${T[$i]}" && b=$i; done
  fstart=$n
  if [ "$b" -ge 1 ]; then
    start=$((b + 1))
    fstart=$start
    for ((i = start; i < n; i++)); do
      [[ "${T[$i]}" =~ $FOOTER_RE ]] || { fstart=$n; break; }
    done
  fi

  for ((i = 0; i < n; i++)); do
    line="${T[$i]}"
    is_blank "$line" && continue

    if printf '%s\n' "$line" | grep -Eiq -- "$ATTRIBUTION_RE"; then
      err "${N[$i]}" "AI-attribution not allowed: $line"
    fi
    if printf '%s\n' "$line" | grep -Eiq -- '^breaking[ -]change:' &&
       ! [[ "$line" =~ ^BREAKING[\ -]CHANGE: ]]; then
      err "${N[$i]}" "breaking-change token must be uppercase (BREAKING CHANGE or BREAKING-CHANGE): $line"
    fi

    [ "$i" -eq 0 ] && continue

    if [[ "$line" =~ $HEADER_ATTEMPT_RE ]]; then
      check_header "$line" "${N[$i]}"
    fi
    if [ "${#line}" -gt "$MAX_LEN" ]; then
      warn "${N[$i]}" "line exceeds $MAX_LEN chars (${#line})"
    fi
    if [ "$i" -ge "$fstart" ] && [[ "$line" =~ ^BREAKING[\ -]CHANGE: ]]; then
      breaking="${N[$i]}"
    fi
  done

  if [ -n "$breaking" ] && [ -z "$bang" ]; then
    warn "$breaking" "BREAKING CHANGE footer without '!' in header"
  fi

  [ "$errors" -eq 0 ]
}

self_test() {
  local pass=0 fail=0
  local a92 a100 a120
  a92="$(printf '%92s' '' | tr ' ' a)"
  a100="$(printf '%100s' '' | tr ' ' a)"
  a120="$(printf '%120s' '' | tr ' ' a)"

  check() {
    local desc="$1" msg="$2" expect_ok="$3" ok
    if validate "$msg" > /dev/null; then ok=true; else ok=false; fi
    if [ "$ok" = "$expect_ok" ]; then
      echo "PASS: $desc"
      pass=$((pass + 1))
    else
      echo "FAIL: $desc"
      fail=$((fail + 1))
    fi
  }

  check "valid single line" \
    'feat(article_search): add live headline/snippet search over the loaded feed' \
    true

  check "valid hybrid multi-line" \
    'fix(dhakapost_source): select the span matching the timestamp pattern

chore(requirements): add playwright dependency' \
    true

  check "hybrid without blank line 2" \
    'fix(dhakapost_source): select the span matching the timestamp pattern
chore(requirements): add playwright dependency' \
    false

  check "bad type" 'oops(home_screen): do a thing' false
  check "missing scope" 'feat: add search' false

  check "AI attribution footer" \
    'feat(home_screen): add search

Co-Authored-By: Claude <noreply@anthropic.com>' \
    false

  check "description too long" \
    'feat(home_screen): this description is deliberately way way way way way way way way way too long to fit under one hundred characters total' \
    false

  check "bang header" 'feat(api)!: drop v1 endpoints' true

  check "bang + BREAKING CHANGE footer" \
    'feat(api)!: drop v1 endpoints

BREAKING CHANGE: use v2' \
    true

  check "BREAKING CHANGE without bang (warns)" \
    'feat(api): drop v1 endpoints

BREAKING CHANGE: use v2' \
    true

  check "lowercase breaking change footer" \
    'feat(api)!: drop v1 endpoints

breaking change: x' \
    false

  check "merge exempt from scope" 'chore: merge dev into master' true

  check "revert exempt from scope" \
    'revert: feat(x): add y

Refs: abc1234' \
    true

  check "footer 'Refs #123'" \
    'fix(x): y

Refs #123' \
    true

  check "header exactly 100 chars" "fix(x): $a92" true
  check "header 101 chars" "fix(x): ${a92}a" false
  check "body line 120 chars (warn only)" \
    "fix(x): y

$a120" \
    true
  [ "${#a100}" -eq 100 ] || { echo "FAIL: self-test helper"; fail=$((fail + 1)); }

  check "hybrid body with bad header-like line" \
    'fix(x): y

oops(x): bad' \
    false

  check "prose body + footers" \
    'fix(x): y

Some prose explaining why.
More prose here.

Refs: 123
Reviewed-by: Someone' \
    true

  check "only comment lines (empty)" \
    '# Please enter the commit message
# lines starting with # are ignored' \
    false

  echo "---"
  echo "$pass passed, $fail failed"
  [ "$fail" -eq 0 ]
}

main() {
  if [ "${1:-}" = "--self-test" ]; then
    self_test
    exit $?
  fi

  local msg
  if [ -n "${1:-}" ]; then
    msg="$(cat "$1")"
  else
    msg="$(cat)"
  fi

  validate "$msg"
}

main "$@"
