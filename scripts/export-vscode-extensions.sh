#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT="${1:-$SCRIPT_DIR/../extensions.json}"

if ! command -v code >/dev/null 2>&1; then
  echo "ERROR: VS Code CLI 'code' was not found in PATH." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required to write JSON." >&2
  exit 1
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

code --list-extensions --show-versions > "$tmp"

python3 - "$tmp" "$OUTPUT" <<'PY'
import json, sys

source, output = sys.argv[1], sys.argv[2]
extensions = []

with open(source, encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line or "@" not in line:
            continue
        ext_id, version = line.rsplit("@", 1)
        extensions.append({"id": ext_id, "version": version})

extensions.sort(key=lambda x: x["id"].lower())

data = {
    "schemaVersion": 1,
    "description": "Portable VS Code extension set. Contains extension IDs and versions only; no workstation-specific paths or personal data.",
    "installDefault": "latest",
    "extensions": extensions,
}

with open(output, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")

print(f"Exported {len(extensions)} extensions to: {output}")
PY
