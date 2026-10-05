#!/usr/bin/env bash
# Validate + commit (and optionally push). Never stages broadly.
#
# Usage:
#   commit.sh <msgfile> [--add <path>...]   (paths are repo-toplevel-relative)
#   commit.sh --push-only
#   commit.sh --self-test

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

do_commit() {
  local msgfile="$1"; shift
  if [ ! -f "$msgfile" ]; then
    echo "error: message file not found: $msgfile" >&2
    return 1
  fi
  local vout
  if ! vout=$("$SCRIPT_DIR/validate_commit_message.sh" "$msgfile" 2>&1); then
    echo "$vout"
    return 1
  fi

  if [ "${1:-}" = "--add" ]; then
    shift
    local top p abs
    top=$(git rev-parse --show-toplevel) || return 1
    top=$(cd "$top" && pwd -P)
    for p in "$@"; do
      case "$p" in
        .|-A|--all|'*') echo "error: refusing broad add: $p" >&2; return 1 ;;
      esac
      case "$p" in /*) abs="$p" ;; *) abs="$top/$p" ;; esac  # paths are toplevel-relative
      if [ -d "$abs" ]; then
        abs=$(cd "$abs" && pwd -P)
        if [ "$abs" = "$top" ]; then
          echo "error: refusing to add repo root: $p" >&2; return 1
        fi
      fi
    done
    [ "$#" -gt 0 ] && { git -C "$top" add -- "$@" || return 1; }
  fi

  if git diff --cached --quiet && [ ! -e "$(git rev-parse --git-path MERGE_HEAD)" ]; then
    echo "error: nothing staged" >&2
    return 1
  fi

  git commit -F "$msgfile" || return $?
  git log --oneline -1
}

do_push() {
  if git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    echo "+ git push"
    git push
  else
    echo "+ git push -u origin HEAD"
    git push -u origin HEAD
  fi
}

self_test() {
  local pass=0 fail=0 me
  me="$SCRIPT_DIR/$(basename "$0")"
  tmp=$(mktemp -d) || exit 1
  trap 'rm -rf "$tmp"' EXIT
  cd "$tmp" || exit 1
  git init -q . && git config user.name t && git config user.email t@t
  git config commit.gpgsign false
  mkdir sub

  t() { # desc, want_rc, actual_rc
    if [ "$2" = "$3" ]; then echo "PASS: $1"; pass=$((pass+1)); else echo "FAIL: $1 (rc=$3)"; fail=$((fail+1)); fi
  }
  count() { git rev-list --count HEAD 2>/dev/null || echo 0; }

  echo hi > f.txt
  echo 'feat(core): add thing' > "$tmp/m1"
  "$me" "$tmp/m1" --add f.txt >/dev/null 2>&1; t "valid commit rc" 0 $?
  t "commit created" 1 "$(count)"
  case "$(git log --oneline -1)" in *"feat(core): add thing"*) t "log shows header" 0 0;; *) t "log shows header" 0 1;; esac

  mkdir -p sub/deep; echo s > sub/file.txt
  echo 'feat(sub): add sub file' > "$tmp/m4"
  (cd sub/deep && "$me" "$tmp/m4" --add sub/file.txt >/dev/null 2>&1); t "--add toplevel-relative from subdir" 0 $?
  t "subdir commit created" 2 "$(count)"

  echo 2 > g.txt
  echo 'bad message' > "$tmp/m2"
  "$me" "$tmp/m2" --add g.txt >/dev/null 2>&1; t "invalid msg rc" 1 $?
  t "no commit on invalid" 2 "$(count)"

  "$me" "$tmp/m1" --add . >/dev/null 2>&1; t "--add . refused" 1 $?
  "$me" "$tmp/m1" --add "$tmp" >/dev/null 2>&1; t "--add toplevel refused" 1 $?
  "$me" "$tmp/m1" --add -A >/dev/null 2>&1; t "--add -A refused" 1 $?
  t "still 2 commits" 2 "$(count)"

  git reset -q
  "$me" "$tmp/m1" >/dev/null 2>&1; t "nothing staged refused" 1 $?

  printf 'feat(x): a\n\nchore(y): b\n' > "$tmp/m3"
  echo 3 > h.txt
  "$me" "$tmp/m3" --add h.txt >/dev/null 2>&1; t "hybrid commit rc" 0 $?
  if [ "$(git log -1 --format=%B)" = "$(printf 'feat(x): a\n\nchore(y): b\n')" ]; then t "hybrid preserved" 0 0; else t "hybrid preserved" 0 1; fi

  echo "passed=$pass failed=$fail"
  [ "$fail" -eq 0 ]
}

main() {
  case "${1:-}" in
    --self-test) self_test ;;
    --push-only) do_push ;;
    "") echo "usage: commit.sh <msgfile> [--add <path>...] | --push-only | --self-test" >&2; return 1 ;;
    *) local f="$1"; shift; do_commit "$f" "$@" ;;
  esac
}

main "$@"
