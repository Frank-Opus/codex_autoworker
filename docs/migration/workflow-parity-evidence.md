# Workflow Parity Evidence

This document records the Phase 3 proof that the Codex-native Autoworker workflow preserves the intended execution semantics: planning writes durable state, dispatch resumes from file-backed state, testing produces observed evidence, and failures are pushed back through the loop instead of being hand-waved away.

## What was exercised

### 1. Planning path

Command:

```bash
./scripts/verify-workflow-parity.sh
```

The first harness stage copies `tests/fixtures/parity-workflow/template/` into a temporary workspace, seeds that workspace with the migrated Codex surfaces (`AGENTS.md`, `.agents/skills/`, `.codex/hooks/`), initializes it as a disposable Git repo so the hook paths resolve the same way they do in the real project, and runs a real `codex exec` prompt that invokes `$deep-plan`.

Pass criteria:
- `task_plan.md` is created
- `task_plan.md` includes the requested `Hello, Codex!` / `Hello, Alice!` acceptance path
- `app.py` and `test_app.py` remain unchanged, proving planning did not silently implement code

### 2. Happy-path execution with fresh-session resume

The second harness stage copies the generated `task_plan.md` into a fresh workspace, seeds the same Codex surfaces, and then uses three separate `codex exec` sessions:

1. `$subtask-init`
2. `$subtask-plan`
3. `$dispatch`

Pass criteria:
- the same active `subtask_*.md` survives across fresh Codex sessions
- `app.py` remains unchanged through planning/setup and changes only during the dispatch-driven execution loop
- the final subtask records executed L1-L4 evidence and `Gate result: PASS`
- the final code updates the default greeting to `Hello, Codex!` while preserving `Hello, Alice!`

This is the concrete proof for file-backed resume semantics in Codex CLI: each session re-enters from disk state instead of relying on previous chat context.

### 3. Recovery / retry path

The third harness stage deliberately injects a regression after the subtask is fully planned:

- `test_app.py` is changed to expect `Hello, Codex!`
- `app.py` is left at `Hello, world!`
- the subtask plan checkboxes are marked complete so `$dispatch` must enter the verification path instead of the implementation path

From that inconsistent starting point, a fresh `codex exec` run in another seeded workspace invokes `$dispatch` and must still converge to a terminal PASS state.

Pass criteria:
- the workflow repairs `app.py` during the verification/recovery loop even though the implementation phases were already marked complete
- the subtask ends with recorded evidence and `Gate result: PASS`
- the repaired workspace matches the expected final behavior

This is the proof that validation gaps discovered after planning are fed back into the workflow rather than bypassed.

## Why the fixture is intentionally tiny

The fixture under `tests/fixtures/parity-workflow/template/` is deliberately small so the parity proof isolates workflow behavior instead of app complexity. The goal is not to test Python; the goal is to test that Codex-native Autoworker still enforces:

- plan before execution
- file-backed state transitions
- evidence-backed verification
- recovery through the workflow instead of ad-hoc completion claims

## Re-run instructions

```bash
./scripts/verify-workflow-parity.sh
```

Optional:

```bash
KEEP_WORKFLOW_PARITY_TMP=1 ./scripts/verify-workflow-parity.sh
```

When `KEEP_WORKFLOW_PARITY_TMP=1` is set, the script prints the temp directory so the intermediate Codex logs and transient workspaces can be inspected manually.
