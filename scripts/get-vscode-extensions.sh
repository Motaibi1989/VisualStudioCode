#!/usr/bin/env bash
set -euo pipefail

if ! command -v code >/dev/null 2>&1; then
  echo "ERROR: VS Code CLI 'code' was not found in PATH." >&2
  exit 1
fi

printf "%-55s %s\n" "EXTENSION" "VERSION"
printf "%-55s %s\n" "---------" "-------"

code --list-extensions --show-versions |
while IFS= read -r line; do
  id="${line%@*}"
  version="${line##*@}"
  printf "%-55s %s\n" "$id" "$version"
done
