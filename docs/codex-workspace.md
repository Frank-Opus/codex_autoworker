# Codex Workspace Usage

Use this repository directly in Codex CLI without plugin packaging.

## Entry Points

- `$autoworker` for a non-trivial task that needs the full loop
- `$deep-plan` when you want the planning discussion explicitly separated first
- `$subtask-init` when a written plan already exists and execution should begin now
- `$dispatch` when resuming from an active `subtask_*.md`
- `python3 scripts/autoworker_state.py --json --write-state` when you want the durable workflow snapshot that hooks also use

## Repo Surfaces

- `AGENTS.md` provides repo-wide always-on guidance
- `.agents/skills/` exposes the migrated workflow skills directly to Codex
- `.codex/hooks.json` adds optional reminders for recovery and persistence
- `.local/autoworker/state.json` stores the latest machine-readable workflow snapshot for autonomous resume
- `scripts/verify-hooks.sh` and `scripts/verify-codex-workspace.sh` validate the repo-native setup

## Hook Enablement

Hooks are optional support, not the main correctness layer. To enable them in Codex, add this feature flag in `~/.codex/config.toml`:

```toml
[features]
codex_hooks = true
```

When enabled, Codex will load both `~/.codex/hooks.json` and `<repo>/.codex/hooks.json` when present.

## Validation

Run these from the repo root:

```bash
./scripts/verify-hooks.sh
./scripts/verify-codex-workspace.sh
./scripts/verify-autonomy-surface.sh
```

The second script performs a real `codex exec` run to confirm that `AGENTS.md` and `.agents/skills/` are visible from the workspace.
The third script checks the durable state snapshot plus hook-driven resume guidance for active subtasks.
