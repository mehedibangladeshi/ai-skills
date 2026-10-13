#!/bin/bash
# Shared fixture: tiny shell project in a git repo with a baseline commit.
set -e
mkdir -p tests
cat > utils.sh <<'SH'
#!/bin/bash
# foo: print the sum of two integers
foo() { echo $(( $1 + $2 )); }
# avg: average of args (bug: divides by zero on no args, integer division)
avg() { local s=0; for n in "$@"; do s=$((s + n)); done; echo $((s / $#)); }
# first_line: print first line of a file (bug: unquoted path)
first_line() { head -n 1 $1; }
SH
cat > report.sh <<'SH'
#!/bin/bash
source "$(dirname "$0")/utils.sh"
total=$(foo "${1:-0}" "${2:-0}")
echo "total: $total"
SH
cat > tests/test_report.sh <<'SH'
#!/bin/bash
out=$(bash "$(dirname "$0")/../report.sh" 2 3)
[ "$out" = "total: 5" ] && echo PASS || { echo "FAIL: $out"; exit 1; }
SH
echo "1.4.0" > VERSION
printf '# Changelog\n\n## 1.4.0\n- report.sh prints totals\n' > CHANGELOG.md
git init -q
git config user.email eval@example.com
git config user.name eval
git add -A
git commit -qm "baseline"
