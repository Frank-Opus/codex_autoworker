# Autoworker for Codex CLI

Autoworker is a Codex-first execution workflow that keeps the plan -> implement -> test -> gate loop on disk instead of trusting optimistic chat summaries.

The repo is built for people who want Codex to keep moving autonomously while still proving completion with real evidence.

## What you get

- A strict state-machine workflow: `$deep-plan` -> `$subtask-init` -> `$subtask-plan` -> `$dispatch`
- Evidence-first completion rules: tests and gate checks must record observed results
- File-backed resume: active `subtask_*.md` state survives fresh Codex sessions
- Optional hook reminders for persistence, without making hooks the correctness layer
- Repo-native usage first, optional plugin packaging second

## Repo-native install

Open the repository directly in Codex CLI. The canonical runtime assets live here:

- `AGENTS.md` — always-on project guidance
- `.agents/skills/` — Codex-discoverable workflow skills
- `.codex/hooks.json` and `.codex/hooks/` — optional reminder hooks
- `scripts/` — validators, migration helpers, and packaging sync scripts

Recommended entry points:

- `$autoworker` — full autonomous loop for non-trivial work
- `$deep-plan` — explicit planning before execution
- `$subtask-init` — start execution from an existing `task_plan.md`
- `$dispatch` — resume an active `subtask_*.md`

## Quick start

### 1. Plan a task

```text
$deep-plan
Add retry logic to the API client and prove it with L1-L4 verification.
```

This writes `task_plan.md` with motivation, assumptions, design decisions, acceptance criteria, and an execution plan.

### 2. Start execution from the plan

```text
$subtask-init
Use the existing task_plan.md and begin the workflow.
```

Autoworker will create `subtask_*.md`, verify assumptions with commands, build the L1-L4 verification plan, and route into the execution loop.

### 3. Resume safely

```text
$dispatch
```

`$dispatch` re-reads file state and decides the next valid step. That makes it the correct resume command after a fresh Codex session, interruption, or context loss.

## Validation commands

Run these from repo root:

```bash
./scripts/verify-hooks.sh
./scripts/verify-codex-workspace.sh
bash -n ./scripts/verify-workflow-parity.sh
./scripts/verify-plugin-package.sh
```

Notes:
- `./scripts/verify-codex-workspace.sh` performs a real `codex exec` visibility check.
- `./scripts/verify-workflow-parity.sh` is the repeatable Phase 3 parity harness; it may require provider capacity because it runs multiple real Codex sessions.
- `./scripts/verify-plugin-package.sh` validates the optional packaged plugin snapshot against the canonical `.agents/skills/` tree.

## Optional plugin package

If you want an installable Codex plugin snapshot instead of repo-native usage, this repo includes:

- `plugins/autoworker-codex/.codex-plugin/plugin.json`
- `plugins/autoworker-codex/skills/`
- `.agents/plugins/marketplace.json`

The plugin package is a distribution snapshot of the canonical repo runtime. When the canonical skills change, refresh the package with:

```bash
./scripts/sync-plugin-package.sh
```

## Migration notes

Codex-first migration docs live under `docs/migration/`.

Start here:

- `docs/migration/codex-compatibility-matrix.md`
- `docs/migration/codex-hooks-and-fallbacks.md`
- `docs/migration/workflow-parity-evidence.md`
- `docs/migration/codex-migration-notes.md`

## Current layout

```text
.
├── AGENTS.md
├── .agents/skills/
├── .agents/plugins/marketplace.json
├── .codex/hooks.json
├── docs/migration/
├── plugins/autoworker-codex/
└── scripts/
```

## Legacy note

The top-level `skills/` directory remains in the repo only as migration-era source material. The Codex runtime surface for this milestone is `.agents/skills/`.

## License

MIT
