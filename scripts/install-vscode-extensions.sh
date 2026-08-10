#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${1:-$SCRIPT_DIR/../extensions.json}"
MODE="${2:-latest}"

if ! command -v code >/dev/null 2>&1; then
  echo "ERROR: VS Code CLI 'code' was not found in PATH." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required to read extensions.json." >&2
  exit 1
fi

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: Config not found: $CONFIG" >&2
  exit 1
fi

declare -A INSTALLED
while IFS= read -r line; do
  id="${line%@*}"
  version="${line##*@}"
  INSTALLED["$id"]="$version"
done < <(code --list-extensions --show-versions)

total=0
installed_count=0
skipped=0
failed=0

while IFS=$'\t' read -r id version; do
  [[ -z "$id" ]] && continue
  ((total+=1))

  if [[ "$MODE" != "pinned" && -n "${INSTALLED[$id]+x}" ]]; then
    echo "[SKIP] $id@${INSTALLED[$id]}"
    ((skipped+=1))
    continue
  fi

  target="$id"
  if [[ "$MODE" == "pinned" && -n "$version" ]]; then
    target="$id@$version"
  fi

  echo "[INSTALL] $target"
  if code --install-extension "$target" --force; then
    echo "[OK] $target"
    ((installed_count+=1))
  else
    echo "[FAIL] $target" >&2
    ((failed+=1))
  fi
done < <(
  python3 - "$CONFIG" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8-sig") as f:
    data = json.load(f)
for ext in data.get("extensions", []):
    print(f"{ext.get('id','')}\t{ext.get('version','')}")
PY
)

echo
echo "VS Code extension installation summary"
printf "%-10s: %s\n" "Total" "$total"
printf "%-10s: %s\n" "Installed" "$installed_count"
printf "%-10s: %s\n" "Skipped" "$skipped"
printf "%-10s: %s\n" "Failed" "$failed"

[[ "$failed" -eq 0 ]]
