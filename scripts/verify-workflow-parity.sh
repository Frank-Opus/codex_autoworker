#!/usr/bin/env bash
set -euo pipefail

ROOT=$(git rev-parse --show-toplevel)
FIXTURE="$ROOT/tests/fixtures/parity-workflow/template"
KEEP_TMP=${KEEP_WORKFLOW_PARITY_TMP:-0}
RUN_DIR=$(mktemp -d "${TMPDIR:-/tmp}/autoworker-parity.XXXXXX")

cleanup() {
  if [[ "$KEEP_TMP" == "1" ]]; then
    echo "workflow-parity temp kept at: $RUN_DIR" >&2
  else
    rm -rf "$RUN_DIR"
  fi
}
trap cleanup EXIT

require_file() {
  local path="$1"
  [[ -f "$path" ]] || {
    echo "missing required file: $path" >&2
    exit 1
  }
}

copy_fixture() {
  local dest="$1"
  mkdir -p "$dest"
  cp -R "$FIXTURE"/. "$dest"/
  find "$dest" -name '__pycache__' -prune -exec rm -rf {} +
}

seed_codex_surfaces() {
  local dest="$1"
  mkdir -p "$dest/.agents" "$dest/.codex"
  cp "$ROOT/AGENTS.md" "$dest/AGENTS.md"
  cp -R "$ROOT/.agents/skills" "$dest/.agents/skills"
  cp "$ROOT/.codex/hooks.json" "$dest/.codex/hooks.json"
  cp -R "$ROOT/.codex/hooks" "$dest/.codex/hooks"
  (
    cd "$dest"
    git init -q
  )
}

run_codex_until() {
  local workdir="$1"
  local log="$2"
  local prompt="$3"
  local condition="$4"
  local timeout_seconds="${5:-240}"
  local attempt
  local pid

  for attempt in 1 2 3; do
    : >"$log"
    sh -c "codex exec --skip-git-repo-check --dangerously-bypass-approvals-and-sandbox --cd \"$workdir\" '$prompt'" >"$log" 2>&1 &
    pid=$!

    for ((elapsed = 0; elapsed < timeout_seconds; elapsed += 2)); do
      if bash -lc "$condition"; then
        pkill -TERM -P "$pid" 2>/dev/null || true
        kill -TERM "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
        return 0
      fi

      if ! kill -0 "$pid" 2>/dev/null; then
        break
      fi

      sleep 2
    done

    if bash -lc "$condition"; then
      pkill -TERM -P "$pid" 2>/dev/null || true
      kill -TERM "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      return 0
    fi

    wait "$pid" 2>/dev/null || true

    if grep -q '429 Too Many Requests' "$log" && [[ "$attempt" -lt 3 ]]; then
      sleep $((attempt * 5))
      continue
    fi
  done

  echo "codex exec did not reach the expected state in $workdir" >&2
  cat "$log" >&2
  exit 1
}

active_subtask() {
  python3 - "$1" <<'PY'
from pathlib import Path
import sys
workdir = Path(sys.argv[1])
files = sorted(workdir.glob('subtask_*.md'))
if not files:
    raise SystemExit('no subtask found')
active = []
for path in files:
    text = path.read_text()
    if 'status: active' in text:
        active.append(path)
if len(active) == 1:
    print(active[0])
elif len(active) == 0 and len(files) == 1:
    print(files[0])
else:
    raise SystemExit(f'could not determine active subtask from {[str(p) for p in files]}')
PY
}

require_file "$FIXTURE/app.py"
require_file "$FIXTURE/test_app.py"
require_file "$ROOT/.agents/skills/deep-plan/SKILL.md"
require_file "$ROOT/.agents/skills/dispatch/SKILL.md"
require_file "$ROOT/AGENTS.md"
require_file "$ROOT/.codex/hooks.json"
require_file "$ROOT/.codex/hooks/session_start_context.py"
require_file "$ROOT/.codex/hooks/stop_persist_state.py"

PLAN_WS="$RUN_DIR/plan"
EXEC_WS="$RUN_DIR/exec"
RECOVERY_WS="$RUN_DIR/recovery"

copy_fixture "$PLAN_WS"
seed_codex_surfaces "$PLAN_WS"
run_codex_until "$PLAN_WS" "$RUN_DIR/plan.log" 'Use $deep-plan for this tiny Python workspace. The implementation task is to change the default greeting to "Hello, Codex!" while keeping `greeting("Alice")` unchanged and updating the regression expectation accordingly. Planning inputs are already decided: main reason = regression sync plus CLI polish; exact scope = only the default greeting path plus the matching regression expectation; downside if skipped = wrong default output and misleading verification coverage. Do not ask follow-up questions. For this planning run, write `task_plan.md` only and do not modify source files.' "[ -f \"$PLAN_WS/task_plan.md\" ]"
python3 - "$PLAN_WS" <<'PY'
from pathlib import Path
import sys
workdir = Path(sys.argv[1])
plan = (workdir / 'task_plan.md')
assert plan.exists(), 'task_plan.md was not created'
plan_text = plan.read_text()
assert 'Hello, Codex!' in plan_text
assert 'Hello, Alice!' in plan_text
assert 'Acceptance Criteria' in plan_text
assert (workdir / 'app.py').read_text().count('Hello, world!') == 1
assert 'Hello, Codex!' not in (workdir / 'app.py').read_text()
assert (workdir / 'test_app.py').read_text().count('Hello, world!') == 1
assert not list(workdir.glob('subtask_*.md'))
PY

copy_fixture "$EXEC_WS"
seed_codex_surfaces "$EXEC_WS"
cp "$PLAN_WS/task_plan.md" "$EXEC_WS/task_plan.md"
run_codex_until "$EXEC_WS" "$RUN_DIR/exec-init.log" '$subtask-init Use the existing `task_plan.md` in this directory. Create or update the active subtask, record assumption verification, and stop before any code changes.' "python3 - <<'PY'
from pathlib import Path
workdir = Path('$EXEC_WS')
files = list(workdir.glob('subtask_*.md'))
if len(files) != 1:
    raise SystemExit(1)
text = files[0].read_text()
assert 'status: active' in text
assert '## Core Assumptions' in text
assert '| Result |' in text
assert 'tests-ok' in text
PY"
EXEC_SUBTASK=$(active_subtask "$EXEC_WS")
python3 - "$EXEC_WS" "$EXEC_SUBTASK" <<'PY'
from pathlib import Path
import sys
workdir = Path(sys.argv[1])
subtask = Path(sys.argv[2])
text = subtask.read_text()
assert 'status: active' in text
assert '## Core Assumptions' in text
assert 'Python 3 is available' in text
assert '## Verification Plan' in text
assert 'Hello, world!' in (workdir / 'app.py').read_text()
assert 'Hello, Codex!' not in (workdir / 'app.py').read_text()
PY
run_codex_until "$EXEC_WS" "$RUN_DIR/exec-plan.log" '$subtask-plan Finish the verification plan for the active subtask using `task_plan.md`. Stop before code changes.' "python3 - <<'PY'
from pathlib import Path
subtask = Path('$EXEC_SUBTASK')
text = subtask.read_text()
assert '### Upstream Verification Traceability' in text
assert '### L1 Build' in text
assert '### L4 End-to-End' in text
assert '### Acceptance Criteria Coverage Check' in text
PY"
python3 - "$EXEC_WS" "$EXEC_SUBTASK" <<'PY'
from pathlib import Path
import sys
workdir = Path(sys.argv[1])
subtask = Path(sys.argv[2])
text = subtask.read_text()
assert '### Upstream Verification Traceability' in text
assert '### L1 Build' in text
assert '### L4 End-to-End' in text
assert '### Acceptance Criteria Coverage Check' in text
assert 'Hello, world!' in (workdir / 'app.py').read_text()
assert 'Hello, Codex!' not in (workdir / 'app.py').read_text()
PY
run_codex_until "$EXEC_WS" "$RUN_DIR/exec-dispatch.log" '$dispatch Resume from the active subtask and continue autonomously until the workflow reaches terminal PASS state.' "python3 - <<'PY'
from pathlib import Path
subtask = Path('$EXEC_SUBTASK')
text = subtask.read_text()
assert 'status: completed' in text
assert 'Gate result: PASS' in text
PY" 480
python3 - "$EXEC_WS" "$EXEC_SUBTASK" <<'PY'
from pathlib import Path
import sys
workdir = Path(sys.argv[1])
subtask = Path(sys.argv[2])
text = subtask.read_text()
assert 'status: completed' in text
assert 'Gate result: PASS' in text
assert '### L4' in text
assert 'Hello, Codex!' in (workdir / 'app.py').read_text()
assert 'Hello, Codex!' in (workdir / 'test_app.py').read_text()
assert 'tests-ok' in text
assert 'Hello, Alice!' in text
PY

copy_fixture "$RECOVERY_WS"
seed_codex_surfaces "$RECOVERY_WS"
cp "$PLAN_WS/task_plan.md" "$RECOVERY_WS/task_plan.md"
run_codex_until "$RECOVERY_WS" "$RUN_DIR/recovery-init.log" '$subtask-init Use the existing `task_plan.md` in this directory. Create or update the active subtask, record assumption verification, and stop before any code changes.' "python3 - <<'PY'
from pathlib import Path
workdir = Path('$RECOVERY_WS')
files = list(workdir.glob('subtask_*.md'))
if len(files) != 1:
    raise SystemExit(1)
text = files[0].read_text()
assert 'status: active' in text
assert 'tests-ok' in text
PY"
RECOVERY_SUBTASK=$(active_subtask "$RECOVERY_WS")
run_codex_until "$RECOVERY_WS" "$RUN_DIR/recovery-plan.log" '$subtask-plan Finish the verification plan for the active subtask using `task_plan.md`. Stop before code changes.' "python3 - <<'PY'
from pathlib import Path
subtask = Path('$RECOVERY_SUBTASK')
text = subtask.read_text()
assert '### Upstream Verification Traceability' in text
assert '### L4 End-to-End' in text
PY"
python3 - "$RECOVERY_WS" "$RECOVERY_SUBTASK" <<'PY'
from pathlib import Path
import re
import sys
workdir = Path(sys.argv[1])
subtask = Path(sys.argv[2])

test_path = workdir / 'test_app.py'
test_path.write_text(test_path.read_text().replace('Hello, world!', 'Hello, Codex!'))

text = subtask.read_text()
match = re.search(r'## Plan\n(.*?)(\n## Reference Files)', text, re.S)
assert match, 'could not find plan section'
plan_block = match.group(1)
updated_plan = re.sub(r'^- \[ \]', '- [x]', plan_block, flags=re.M)
assert updated_plan != plan_block, 'plan section had no unchecked steps to flip'
text = text.replace(plan_block, updated_plan, 1)
text = text.replace('status: completed', 'status: active')
text = text.replace('Gate result: PASS', '')
subtask.write_text(text)

assert 'Hello, world!' in (workdir / 'app.py').read_text()
assert 'Hello, Codex!' in (workdir / 'test_app.py').read_text()
PY
run_codex_until "$RECOVERY_WS" "$RUN_DIR/recovery-dispatch.log" '$dispatch Resume from the active subtask and continue autonomously until the workflow reaches terminal PASS state.' "python3 - <<'PY'
from pathlib import Path
workdir = Path('$RECOVERY_WS')
subtask = Path('$RECOVERY_SUBTASK')
text = subtask.read_text()
assert 'status: completed' in text
assert 'Gate result: PASS' in text
assert 'Hello, Codex!' in (workdir / 'app.py').read_text()
PY" 480
python3 - "$RECOVERY_WS" "$RECOVERY_SUBTASK" <<'PY'
from pathlib import Path
import sys
workdir = Path(sys.argv[1])
subtask = Path(sys.argv[2])
text = subtask.read_text()
assert 'status: completed' in text
assert 'Gate result: PASS' in text
assert 'Hello, Codex!' in (workdir / 'app.py').read_text(), 'recovery run did not repair app.py'
assert 'Hello, Codex!' in (workdir / 'test_app.py').read_text()
assert 'tests-ok' in text
assert 'Hello, Alice!' in text
PY

printf 'workflow-parity-ok\n'
