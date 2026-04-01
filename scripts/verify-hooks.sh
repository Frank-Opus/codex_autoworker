#!/usr/bin/env bash
set -euo pipefail

ROOT=$(git rev-parse --show-toplevel)
HOOKS_JSON="$ROOT/.codex/hooks.json"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

extract_command() {
  local event="$1"
  python3 - "$HOOKS_JSON" "$event" <<'PY'
import json
import sys
from pathlib import Path
hooks = json.loads(Path(sys.argv[1]).read_text())
event = sys.argv[2]
print(hooks["hooks"][event][0]["hooks"][0]["command"])
PY
}

SESSION_CMD=$(extract_command SessionStart)
STOP_CMD=$(extract_command Stop)

cat > "$TMPDIR/session.json" <<JSON
{"cwd": "$ROOT/docs", "hook_event_name": "SessionStart", "source": "startup", "session_id": "verify-session", "model": "test"}
JSON

cat > "$TMPDIR/stop.json" <<JSON
{"cwd": "$ROOT/docs", "hook_event_name": "Stop", "turn_id": "verify-turn", "session_id": "verify-session", "model": "test", "last_assistant_message": "verification run"}
JSON

( cd "$ROOT/docs" && eval "$SESSION_CMD" < "$TMPDIR/session.json" > "$TMPDIR/session.out" )
( cd "$ROOT/docs" && eval "$STOP_CMD" < "$TMPDIR/stop.json" > "$TMPDIR/stop.out" )

python3 - "$TMPDIR/session.out" "$TMPDIR/stop.out" <<'PY'
import json
import sys
from pathlib import Path
session = json.loads(Path(sys.argv[1]).read_text())
stop = json.loads(Path(sys.argv[2]).read_text())
assert session["hookSpecificOutput"]["hookEventName"] == "SessionStart"
assert "Autoworker" in session["hookSpecificOutput"]["additionalContext"]
assert stop["continue"] is True
print("hooks-ok")
PY
