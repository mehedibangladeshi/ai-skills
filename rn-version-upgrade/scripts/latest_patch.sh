#!/usr/bin/env bash
# Resolves a React Native minor version (e.g. "0.84") to the latest stable
# patch published on npm (e.g. "0.84.9"). Excludes prereleases (-rc, -nightly, etc).
# Usage: latest_patch.sh <minor>
set -uo pipefail

MINOR="${1:?Usage: latest_patch.sh <minor, e.g. 0.84>}"

if ! command -v npm >/dev/null 2>&1; then
  echo "npm not available in this environment" >&2
  exit 1
fi

npm view react-native versions --json 2>/dev/null | node -e "
  let raw = '';
  process.stdin.on('data', (d) => raw += d);
  process.stdin.on('end', () => {
    const versions = JSON.parse(raw);
    const minor = process.argv[1];
    const matches = versions.filter(v => v.startsWith(minor + '.') && !v.includes('-'));
    if (matches.length === 0) {
      console.error('No stable patch found for minor ' + minor);
      process.exit(1);
    }
    console.log(matches[matches.length - 1]);
  });
" "$MINOR"
