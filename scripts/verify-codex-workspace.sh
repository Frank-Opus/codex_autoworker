#!/usr/bin/env bash
set -euo pipefail

ROOT=$(git rev-parse --show-toplevel)
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

for path in "$ROOT/AGENTS.md" "$ROOT/.agents/skills/autoworker/SKILL.md" "$ROOT/.codex/hooks.json"; do
  [[ -f "$path" ]]
done

"$ROOT/scripts/verify-hooks.sh" >/dev/null

cat > "$TMPDIR/schema.json" <<'JSON'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "additionalProperties": false,
  "required": ["saw_agents_md", "skill_names", "mentions_dispatch", "mentions_autoworker", "notes"],
  "properties": {
    "saw_agents_md": {"type": "boolean"},
    "skill_names": {
      "type": "array",
      "items": {"type": "string"},
      "minItems": 2
    },
    "mentions_dispatch": {"type": "boolean"},
    "mentions_autoworker": {"type": "boolean"},
    "notes": {"type": "string"}
  }
}
JSON

codex exec \
  --skip-git-repo-check \
  --dangerously-bypass-approvals-and-sandbox \
  --cd "$ROOT" \
  --output-schema "$TMPDIR/schema.json" \
  -o "$TMPDIR/output.json" \
  'Inspect the current workspace instructions only. Reply as JSON. Confirm whether AGENTS.md is visible, list the Autoworker skills you can see in .agents/skills, and say whether the workflow mentions $dispatch and $autoworker. Do not modify files.' >/dev/null

python3 - "$TMPDIR/output.json" <<'PY'
import json
import sys
from pathlib import Path
payload = json.loads(Path(sys.argv[1]).read_text())
assert payload["saw_agents_md"] is True
skills = set(payload["skill_names"])
assert "autoworker" in skills
assert "dispatch" in skills
assert payload["mentions_dispatch"] is True
assert payload["mentions_autoworker"] is True
print("codex-workspace-ok")
PY
