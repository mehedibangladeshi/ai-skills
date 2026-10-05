#!/usr/bin/env bash
# Read-only snapshot of git state for drafting a commit. Run inside a git repo.
# Prints sections headed "== <name> ==". Never prints the full diff.
#
# Usage:
#   gather_context.sh
#   gather_context.sh --self-test

set -u

gather() {
  local gd sha
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "error: not inside a git repository" >&2
    return 2
  fi

  echo "== branch =="
  local br
  br=$(git branch --show-current 2>/dev/null)
  if [ -n "$br" ]; then
    echo "$br"
  else
    sha=$(git rev-parse --short HEAD 2>/dev/null || echo "?")
    echo "DETACHED $sha"
  fi

  echo "== upstream =="
  git rev-parse --abbrev-ref '@{u}' 2>/dev/null || echo "none"

  local state=clean p
  p=$(git rev-parse --git-path MERGE_HEAD)
  if [ -e "$p" ]; then state=merge
  elif [ -d "$(git rev-parse --git-path rebase-merge)" ] || [ -d "$(git rev-parse --git-path rebase-apply)" ]; then state=rebase
  elif [ -e "$(git rev-parse --git-path CHERRY_PICK_HEAD)" ]; then state=cherry-pick
  elif [ -e "$(git rev-parse --git-path REVERT_HEAD)" ]; then state=revert
  fi
  echo "== state =="
  echo "$state"

  local staged unstaged untracked
  staged=$(git diff --cached --name-status)
  unstaged=$(git diff --name-status)
  untracked=$(git ls-files --others --exclude-standard)
  echo "== staged_files =="; [ -n "$staged" ] && echo "$staged"
  echo "== unstaged_files =="; [ -n "$unstaged" ] && echo "$unstaged"
  echo "== untracked_files =="; [ -n "$untracked" ] && echo "$untracked"

  local side=""   # "--cached" or "" (working tree)
  [ -n "$staged" ] && side="--cached"
  local ns numstat
  if [ -n "$side" ]; then ns="$staged"; else ns="$unstaged"; fi
  numstat=$(git diff $side --numstat)

  echo "== diffstat =="
  git diff $side --stat

  local total
  total=$(printf '%s\n' "$numstat" | awk -F'\t' 'NF>=3 { if ($1 != "-") t+=$1; if ($2 != "-") t+=$2 } END { print t+0 }')
  echo "== total_lines =="
  echo "$total"

  echo "== flags =="
  if [ -z "$staged" ] && [ -z "$unstaged" ] && [ -z "$untracked" ]; then
    echo NOTHING_TO_COMMIT
  elif [ -z "$staged" ]; then
    echo UNSTAGED_ONLY
  fi
  if [ -n "$numstat" ] && ! printf '%s\n' "$numstat" | grep -qv "^-	-	"; then
    echo BINARY_ONLY
  fi
  if [ -n "$ns" ] && ! printf '%s\n' "$ns" | grep -qv '^D'; then
    echo DELETIONS_ONLY
  fi
  [ "$total" -gt 500 ] && echo LARGE_DIFF
  [ "$state" = merge ] && echo MERGE_IN_PROGRESS

  echo "== recent_log =="
  git log --oneline -10 2>/dev/null || echo "(no commits yet)"
  return 0
}

self_test() {
  local pass=0 fail=0 here out
  here="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  tmp=$(mktemp -d) || exit 1
  trap 'rm -rf "$tmp"' EXIT

  new_repo() {
    rm -rf "$tmp/r"; mkdir "$tmp/r"; cd "$tmp/r" || exit 1
    git init -q . && git config user.name t && git config user.email t@t
    git config commit.gpgsign false
  }
  expect() { # desc, pattern(grep -E on output), want(1=present,0=absent)
    local has=0
    printf '%s\n' "$out" | grep -Eq "$2" && has=1
    if [ "$has" = "$3" ]; then echo "PASS: $1"; pass=$((pass+1)); else echo "FAIL: $1"; fail=$((fail+1)); fi
  }
  base() { echo a > a.txt; git add a.txt; git commit -qm "feat(x): base"; }

  new_repo; base
  out=$("$here" 2>&1)
  expect "clean -> NOTHING_TO_COMMIT" '^NOTHING_TO_COMMIT$' 1

  new_repo; base; echo u > u.txt
  out=$("$here" 2>&1)
  expect "untracked only -> UNSTAGED_ONLY" '^UNSTAGED_ONLY$' 1
  expect "untracked only -> not NOTHING_TO_COMMIT" '^NOTHING_TO_COMMIT$' 0

  new_repo; base; git rm -q a.txt
  out=$("$here" 2>&1)
  expect "staged deletion -> DELETIONS_ONLY" '^DELETIONS_ONLY$' 1

  new_repo; base; printf '\x00\x01' > f.bin; git add f.bin
  out=$("$here" 2>&1)
  expect "staged binary -> BINARY_ONLY" '^BINARY_ONLY$' 1

  new_repo; base; seq 1 600 > big.txt; git add big.txt
  out=$("$here" 2>&1)
  expect "600 lines -> LARGE_DIFF" '^LARGE_DIFF$' 1
  expect "600 lines -> total_lines 600" '^600$' 1

  new_repo; base
  git checkout -q -b other; echo o > a.txt; git commit -qam "feat(x): other"
  git checkout -q -; echo m > a.txt; git commit -qam "feat(x): main"
  git merge other >/dev/null 2>&1
  out=$("$here" 2>&1)
  expect "merge conflict -> MERGE_IN_PROGRESS" '^MERGE_IN_PROGRESS$' 1
  expect "merge conflict -> state merge" '^merge$' 1

  new_repo; echo x > x.txt; git add x.txt
  out=$("$here" 2>&1); rc=$?
  expect "no-commit repo: runs, shows log placeholder" 'no commits yet' 1
  [ "$rc" = 0 ] || { echo "FAIL: no-commit rc=$rc"; fail=$((fail+1)); }

  cd "$tmp" && out=$("$here" 2>&1); rc=$?
  if [ "$rc" = 2 ]; then echo "PASS: non-repo exits 2"; pass=$((pass+1)); else echo "FAIL: non-repo rc=$rc"; fail=$((fail+1)); fi

  echo "passed=$pass failed=$fail"
  [ "$fail" -eq 0 ]
}

main() {
  case "${1:-}" in
    --self-test) self_test ;;
    *) gather ;;
  esac
}

main "$@"
