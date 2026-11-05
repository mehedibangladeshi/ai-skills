#!/usr/bin/env bash
# Validates, pushes the current branch, and opens a GitHub PR via gh. Prints only
# the PR URL on the last line. Never commits, never force-pushes.
#
# Usage:
#   send.sh --base <branch> --title-file <f> --body-file <f> [--draft] [--dry-run]
#   send.sh --self-test

set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SELF="$DIR/$(basename "${BASH_SOURCE[0]}")"

usage() {
  echo "usage: send.sh --base <branch> --title-file <f> --body-file <f> [--draft] [--dry-run] | --self-test" >&2
  exit 2
}

self_test() {
  local pass=0 fail=0 work out rec before
  tmp="$(mktemp -d)" || exit 1  # global: EXIT trap runs after this function returns
  trap 'rm -rf "$tmp"' EXIT
  mkdir "$tmp/bin"
  rec="$tmp/gh.argv"
  cat > "$tmp/bin/gh" <<STUB
#!/usr/bin/env bash
echo "\$*" >> "$rec"
echo https://github.com/o/r/pull/1
STUB
  chmod +x "$tmp/bin/gh"
  export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
  git init -q --bare -b main "$tmp/origin.git"
  git clone -q "$tmp/origin.git" "$tmp/work" 2> /dev/null
  work="$tmp/work"
  printf 'feat(x): add y\n' > "$tmp/title"
  printf '## Description\n\nDoes y.\n' > "$tmp/body"
  (cd "$work" && git checkout -q -b main && echo a > f && git add f && git commit -qm init && git push -q origin main \
    && git checkout -q -b feat/y && echo b >> f && git commit -qam y) || { echo "FAIL: setup"; exit 1; }

  t() { # t <desc> <cond-exit-status>
    if [ "$2" -eq 0 ]; then echo "PASS: $1"; pass=$((pass + 1)); else echo "FAIL: $1"; fail=$((fail + 1)); fi
  }
  run() { (cd "$work" && PATH="$tmp/bin:$PATH" bash "$SELF" --base main --title-file "$tmp/title" --body-file "$tmp/body" "$@"); }

  out="$(run --dry-run 2>&1)"
  echo "$out" | grep -q 'git push -u origin HEAD' && echo "$out" | grep -q 'gh pr create --base main --title'
  t "dry-run prints push and gh commands" $?
  [ ! -e "$rec" ] && ! git -C "$tmp/origin.git" rev-parse -q --verify feat/y > /dev/null
  t "dry-run runs neither" $?

  out="$(run 2> /dev/null)"
  [ "$(echo "$out" | tail -n1)" = "https://github.com/o/r/pull/1" ] && [ "$(echo "$out" | wc -l | tr -d ' ')" -eq 1 ]
  t "real run prints only the PR URL" $?
  git -C "$tmp/origin.git" rev-parse -q --verify feat/y > /dev/null
  t "real run pushed to origin" $?
  grep -q '^pr create --base main --title feat(x): add y --body-file ' "$rec" && ! grep -q -- '--draft' "$rec"
  t "gh recorded pr create without --draft" $?

  : > "$rec"; run --draft > /dev/null 2>&1
  grep -q -- '--draft' "$rec"
  t "--draft passed to gh" $?

  out="$(cd "$work" && git checkout -q main && PATH="$tmp/bin:$PATH" bash "$SELF" --base main --title-file "$tmp/title" --body-file "$tmp/body" 2>&1)"
  [ $? -eq 1 ] && echo "$out" | grep -q 'base'
  t "refuses on base branch" $?

  (cd "$work" && PATH="$tmp/bin:$PATH" bash "$SELF" --base main --title-file "$tmp/nope" --body-file "$tmp/body" > /dev/null 2>&1)
  [ $? -eq 2 ]
  t "missing title file -> exit 2" $?

  before="$(git -C "$tmp/origin.git" rev-parse main)"
  (cd "$work" && git checkout -q -b up1 origin/main && echo c >> f && git commit -qam c \
    && git branch --set-upstream-to=origin/main > /dev/null && PATH="$tmp/bin:$PATH" bash "$SELF" --base main --title-file "$tmp/title" --body-file "$tmp/body" > /dev/null 2>&1)
  [ "$(git -C "$tmp/origin.git" rev-parse main)" = "$before" ] && git -C "$tmp/origin.git" rev-parse -q --verify up1 > /dev/null
  t "branch tracking origin/main pushes to its own name" $?

  echo "---"; echo "$pass passed, $fail failed"
  [ "$fail" -eq 0 ]
}

main() {
  local base="" tfile="" bfile="" draft=0 dry=0
  [ "${1:-}" = "--self-test" ] && { self_test; exit $?; }
  while [ $# -gt 0 ]; do
    case "$1" in
      --base) [ $# -ge 2 ] || usage; base="$2"; shift 2 ;;
      --title-file) [ $# -ge 2 ] || usage; tfile="$2"; shift 2 ;;
      --body-file) [ $# -ge 2 ] || usage; bfile="$2"; shift 2 ;;
      --draft) draft=1; shift ;;
      --dry-run) dry=1; shift ;;
      *) usage ;;
    esac
  done
  [ -n "$base" ] && [ -n "$tfile" ] && [ -n "$bfile" ] || usage

  [ -r "$tfile" ] && [ -r "$bfile" ] || { echo "error: --title-file/--body-file must exist and be readable" >&2; usage; }

  "$DIR/validate_pr.sh" "$tfile" "$bfile" || exit 1

  local branch title push gh_args
  branch="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)" || { echo "error: not a git repository" >&2; exit 1; }
  if [ "$branch" = "HEAD" ] || [ "$branch" = "$base" ]; then
    echo "error: current branch '$branch' is the base branch '$base' (or detached); switch to a feature branch" >&2
    exit 1
  fi

  title="$(grep . "$tfile" | head -n1)"
  push=(git push -u origin HEAD)
  gh_args=(pr create --base "$base" --title "$title" --body-file "$bfile")
  [ "$draft" -eq 1 ] && gh_args+=(--draft)

  if [ "$dry" -eq 1 ]; then
    printf '%q ' "${push[@]}"; echo
    printf '%q ' gh "${gh_args[@]}"; echo
    exit 0
  fi

  "${push[@]}" >&2 || { echo "error: push failed" >&2; exit 1; }
  local url
  url="$(gh "${gh_args[@]}")" || { echo "error: gh pr create failed" >&2; exit 1; }
  echo "$url" | tail -n1
}

main "$@"
