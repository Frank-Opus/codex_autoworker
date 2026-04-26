# Codex Workspace Usage

Use this repository directly in Codex CLI. Repo-native usage is the primary path; plugin packaging is optional.

## Start Here

- `AGENTS.md` provides repo-wide always-on guidance
- `.agents/skills/` is the canonical workflow skill tree
- `.codex/hooks.json` adds optional recovery and persistence reminders
- `.local/autoworker/state.json` stores the machine-readable workflow snapshot

If the repository layout looks crowded, read [repo-layout.md](repo-layout.md) before touching legacy or packaged paths.

## Entry Points

- `$autoworker` for a non-trivial task that should run through the full loop
- `$deep-plan` when you want planning explicitly separated first
- `$subtask-init` when a written plan already exists and execution should begin now
- `$dispatch` when resuming from an active `subtask_*.md`
- `python3 scripts/autoworker_state.py --json --write-state` when you want the durable workflow snapshot that hooks also use

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

- `verify-hooks.sh` checks hook wiring and nested-directory path safety
- `verify-codex-workspace.sh` performs a real `codex exec` run to confirm that `AGENTS.md` and `.agents/skills/` are visible from the workspace
- `verify-autonomy-surface.sh` checks the durable state snapshot plus hook-driven resume guidance
