#!/usr/bin/env bash
set -euo pipefail

ROOT=$(git rev-parse --show-toplevel)
PLUGIN_DIR="$ROOT/plugins/autoworker-codex"
MANIFEST="$PLUGIN_DIR/.codex-plugin/plugin.json"
MARKETPLACE="$ROOT/.agents/plugins/marketplace.json"

[[ -f "$MANIFEST" ]]
[[ -f "$MARKETPLACE" ]]
[[ -d "$PLUGIN_DIR/skills" ]]

diff -qr "$ROOT/.agents/skills" "$PLUGIN_DIR/skills" >/dev/null

python3 - "$MANIFEST" "$MARKETPLACE" <<'PY'
import json
import sys
from pathlib import Path
manifest = json.loads(Path(sys.argv[1]).read_text())
marketplace = json.loads(Path(sys.argv[2]).read_text())
assert manifest["name"] == "autoworker-codex"
assert manifest["skills"] == "./skills/"
assert manifest["interface"]["displayName"] == "Autoworker for Codex CLI"
plugins = marketplace["plugins"]
assert len(plugins) == 1
entry = plugins[0]
assert entry["name"] == "autoworker-codex"
assert entry["source"]["source"] == "local"
assert entry["source"]["path"] == "./plugins/autoworker-codex"
assert entry["policy"]["installation"] == "AVAILABLE"
assert entry["policy"]["authentication"] == "ON_INSTALL"
print("plugin-package-ok")
PY
