#!/usr/bin/env bash
# Read-only snapshot of git/gh state for opening a PR. Run inside a git repo.
# Prints sections headed "=== <name> ===". Never pushes, commits, or modifies anything.
#
# Usage:
#   gather_context.sh
#   gather_context.sh --self-test

set -u

SCRIPT="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

gather() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "error: not inside a git repository" >&2
    return 2
  fi
  local root; root=$(git rev-parse --show-toplevel)
  local flags=()

  local br; br=$(git branch --show-current 2>/dev/null)
  [ -z "$br" ] && br=HEAD
  echo "=== branch ==="; echo "$br"

  local has_gh=0 gh_ok=0
  if command -v gh >/dev/null 2>&1; then
    has_gh=1
    gh auth status >/dev/null 2>&1 && gh_ok=1
  fi

  local base
  base=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null); base=${base#origin/}
  if [ -z "$base" ] && [ "$gh_ok" = 1 ]; then
    base=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null)
  fi
  if [ -z "$base" ]; then
    if git rev-parse --verify -q refs/remotes/origin/main >/dev/null; then base=main; else base=master; fi
  fi
  echo "=== base ==="; echo "$base"

  echo "=== upstream ==="
  local up
  up=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || up=""
  if [ -z "$up" ] || [ "$up" = '@{u}' ]; then echo none; else echo "$up"; fi

  local ref="$base"
  git rev-parse --verify -q "refs/remotes/origin/$base" >/dev/null && ref="origin/$base"
  local ahead; ahead=$(git rev-list --count "$ref..HEAD" 2>/dev/null || echo 0)
  echo "=== ahead ==="; echo "$ahead"

  echo "=== commits ==="
  git log --format='%h %s' "$ref..HEAD" 2>/dev/null | head -30

  local total
  total=$(git diff --numstat "$ref...HEAD" 2>/dev/null | awk -F'\t' 'NF>=3 { if ($1 != "-") t+=$1; if ($2 != "-") t+=$2 } END { print t+0 }')
  echo "=== diffstat ==="
  git diff --stat "$ref...HEAD" 2>/dev/null | tail -30
  echo "total_lines: $total"

  echo "=== template ==="
  local f found="" d="$root/.github/PULL_REQUEST_TEMPLATE"
  for f in .github/pull_request_template.md .github/PULL_REQUEST_TEMPLATE.md docs/pull_request_template.md pull_request_template.md PULL_REQUEST_TEMPLATE.md; do
    [ -f "$root/$f" ] && { found="$root/$f"; break; }
  done
  if [ -n "$found" ]; then
    echo "$found"
  elif [ -d "$d" ] && [ -n "$(ls -A "$d" 2>/dev/null)" ]; then
    echo "MULTIPLE $d"
    find "$d" -maxdepth 1 -type f | sort
  else
    echo "BUNDLED $(cd "$(dirname "$SCRIPT")/../templates" 2>/dev/null && pwd || dirname "$SCRIPT")/pull_request_template.md"
  fi

  echo "=== pr ==="
  local pr=none
  if [ "$gh_ok" = 1 ]; then
    pr=$(gh pr view --json url,state,number -q '"\(.number) \(.state) \(.url)"' 2>/dev/null) || pr=none
    [ -z "$pr" ] && pr=none
  fi
  echo "$pr"

  [ -n "$(git status --porcelain 2>/dev/null)" ] && flags+=(DIRTY_TREE)
  [ "$br" = "$base" ] && flags+=(ON_DEFAULT_BRANCH)
  [ "$ahead" -eq 0 ] && flags+=(NO_COMMITS_AHEAD)
  case "$pr" in *" OPEN "*) flags+=(PR_EXISTS) ;; esac
  [ "$has_gh" = 0 ] && flags+=(GH_MISSING)
  [ "$has_gh" = 1 ] && [ "$gh_ok" = 0 ] && flags+=(GH_UNAUTH)
  [ "$total" -gt 1000 ] && flags+=(LARGE_DIFF)
  git remote | grep -qx origin || flags+=(NO_ORIGIN)

  echo "=== flags ==="
  if [ ${#flags[@]} -eq 0 ]; then echo none; else printf '%s\n' "${flags[@]}"; fi
  return 0
}

self_test() {
  local pass=0 fail=0 out
  tmp=$(mktemp -d) || exit 1
  trap 'rm -rf "$tmp"' EXIT
  mkdir "$tmp/bin"
  # Stub gh: authed, no PR, default branch main. Never touches the network.
  cat > "$tmp/bin/gh" <<'STUB'
#!/bin/sh
case "$1 $2" in
  "auth status") exit 0 ;;
  "repo view") echo main; exit 0 ;;
  *) exit 1 ;;
esac
STUB
  chmod +x "$tmp/bin/gh"
  export PATH="$tmp/bin:$PATH"

  expect() { # desc, pattern, want(1=present,0=absent)
    local has=0
    printf '%s\n' "$out" | grep -Eq "$2" && has=1
    if [ "$has" = "$3" ]; then echo "PASS: $1"; pass=$((pass+1)); else echo "FAIL: $1"; fail=$((fail+1)); fi
  }
  new_repo() {
    rm -rf "$tmp/o.git" "$tmp/w"
    git init -q --bare -b main "$tmp/o.git"
    git clone -q "$tmp/o.git" "$tmp/w" 2>/dev/null
    cd "$tmp/w" || exit 1
    git config user.name t; git config user.email t@t; git config commit.gpgsign false
    git checkout -q -b main 2>/dev/null
    echo a > a.txt; git add a.txt; git commit -qm "feat(x): base"
    git push -q origin main 2>/dev/null
    git remote set-head origin main >/dev/null 2>&1
  }
  flags_of() { printf '%s\n' "$out" | sed -n '/^=== flags ===$/,$p' | tail -n +2; }

  new_repo; git checkout -q -b feat; echo b > b.txt; git add b.txt; git commit -qm "feat(x): one"
  out=$("$SCRIPT" 2>&1)
  expect "section order intact" '^=== branch ===$' 1
  expect "base resolved to main" '^main$' 1
  expect "ahead 1" '^1$' 1
  expect "commits lists subject" 'feat\(x\): one' 1
  expect "bundled template" '^BUNDLED .*/templates/pull_request_template.md$' 1
  [ "$(flags_of)" = none ] && { echo "PASS: clean branch -> flags none"; pass=$((pass+1)); } || { echo "FAIL: clean branch flags: $(flags_of)"; fail=$((fail+1)); }

  [ "$(printf '%s\n' "$out" | sed -n '/^=== upstream ===$/,/^=== ahead ===$/p' | sed '1d;$d')" = none ] \
    && { echo "PASS: no upstream -> body is exactly none"; pass=$((pass+1)); } || { echo "FAIL: no upstream body"; fail=$((fail+1)); }

  echo d > d.txt
  out=$("$SCRIPT" 2>&1)
  expect "dirty tree -> DIRTY_TREE" '^DIRTY_TREE$' 1
  rm d.txt

  git checkout -q main
  echo d > d.txt
  out=$("$SCRIPT" 2>&1)
  [ "$(flags_of | tr '\n' ' ')" = "DIRTY_TREE ON_DEFAULT_BRANCH NO_COMMITS_AHEAD " ] \
    && { echo "PASS: flag order"; pass=$((pass+1)); } || { echo "FAIL: flag order: $(flags_of | tr '\n' ' ')"; fail=$((fail+1)); }
  rm d.txt
  out=$("$SCRIPT" 2>&1)
  expect "on main -> ON_DEFAULT_BRANCH" '^ON_DEFAULT_BRANCH$' 1
  expect "on main -> NO_COMMITS_AHEAD" '^NO_COMMITS_AHEAD$' 1

  mkdir -p .github; echo t > .github/pull_request_template.md
  out=$("$SCRIPT" 2>&1)
  expect "repo template found" "/w/.github/pull_request_template.md$" 1
  expect "repo template -> not BUNDLED" '^BUNDLED' 0
  rm -rf .github

  mkdir -p .github/PULL_REQUEST_TEMPLATE; echo t > .github/PULL_REQUEST_TEMPLATE/bug.md
  out=$("$SCRIPT" 2>&1)
  expect "template dir -> MULTIPLE" '^MULTIPLE .*PULL_REQUEST_TEMPLATE$' 1
  expect "template dir lists file" 'PULL_REQUEST_TEMPLATE/bug.md$' 1

  cd "$tmp"
  echo "passed=$pass failed=$fail"
  [ "$fail" -eq 0 ]
}

case "${1:-}" in
  --self-test) self_test ;;
  *) gather ;;
esac
