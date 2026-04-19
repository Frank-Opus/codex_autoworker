#!/usr/bin/env bash
set -euo pipefail

ROOT=$(git rev-parse --show-toplevel)
TMPDIR=$(mktemp -d "${TMPDIR:-/tmp}/autoworker-surface.XXXXXX")
trap 'rm -rf "$TMPDIR"' EXIT

WORKDIR="$TMPDIR/workspace"
mkdir -p "$WORKDIR"

cat > "$WORKDIR/task_plan.md" <<'EOF_PLAN'
# Task Plan

## Acceptance Criteria
- The workflow should resume without asking a human to reconstruct state.
EOF_PLAN

cat > "$WORKDIR/subtask_demo.md" <<'EOF_SUBTASK'
status: active

- [x] L1 build
- [ ] L2 unit

## Verification Notes
Gate result: FAIL
EOF_SUBTASK

(
  cd "$WORKDIR"
  git init -q
)

python3 "$ROOT/scripts/autoworker_state.py" --root "$WORKDIR" --write-state --json > "$TMPDIR/state.json"

python3 - "$TMPDIR/state.json" <<'PY'
import json
import sys
from pathlib import Path
payload = json.loads(Path(sys.argv[1]).read_text())
assert payload["next_command"] == "$dispatch"
assert payload["active_subtask_count"] == 1
assert payload["subtasks"][0]["gate_result"] == "FAIL"
PY

printf '{"cwd": "%s"}' "$WORKDIR" | python3 "$ROOT/.codex/hooks/session_start_context.py" > "$TMPDIR/session-start.json"
python3 - "$TMPDIR/session-start.json" <<'PY'
import json
import sys
from pathlib import Path
payload = json.loads(Path(sys.argv[1]).read_text())
context = payload["hookSpecificOutput"]["additionalContext"]
assert "Recommended next command: $dispatch." in context
assert "Latest workflow snapshot:" in context
PY

printf '{"cwd": "%s"}' "$WORKDIR" | python3 "$ROOT/.codex/hooks/stop_persist_state.py" > "$TMPDIR/stop.json"
python3 - "$TMPDIR/stop.json" "$WORKDIR/.local/autoworker/state.json" <<'PY'
import json
import sys
from pathlib import Path
payload = json.loads(Path(sys.argv[1]).read_text())
snapshot = Path(sys.argv[2])
assert payload["continue"] is True
assert "$dispatch" in payload["systemMessage"]
assert snapshot.exists()
saved = json.loads(snapshot.read_text())
assert saved["next_command"] == "$dispatch"
PY

echo "autonomy-surface-ok"
