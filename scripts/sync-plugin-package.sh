#!/usr/bin/env bash
set -euo pipefail

ROOT=$(git rev-parse --show-toplevel)
PLUGIN_DIR="$ROOT/plugins/autoworker-codex"

mkdir -p "$PLUGIN_DIR"
rm -rf "$PLUGIN_DIR/skills"
cp -R "$ROOT/.agents/skills" "$PLUGIN_DIR/skills"
find "$PLUGIN_DIR/skills" -name '__pycache__' -prune -exec rm -rf {} +

echo "plugin-package-synced"
