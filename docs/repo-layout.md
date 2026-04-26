# Repository Layout

This repository exposes more than one surface because it contains the Codex-native runtime, optional packaging, and migration-era compatibility material.

If you are trying to understand where to work, start with one rule:

> author in the canonical runtime, validate locally, package later if needed

## The three layers

| Layer | Paths | What it means |
|---|---|---|
| Canonical runtime | `AGENTS.md`, `.agents/skills/`, `.codex/hooks.json`, `scripts/` | The primary Codex workflow. This is the source of truth for behavior. |
| Durable workflow state | `task_plan.md`, `subtask_*.md`, `.local/autoworker/state.json` | The files that preserve planning, execution, and recovery across sessions. |
| Optional distribution | `plugins/autoworker-codex/`, `.agents/plugins/marketplace.json` | A packaged snapshot for installation or sharing after repo-native validation. |

## Legacy and compatibility surfaces

These paths still exist, but they are not the main authoring path:

| Path | Status | Why it still exists |
|---|---|---|
| `skills/` | Legacy | Migration source material and compatibility reference while the Codex port settles. |
| `.claude-plugin/` | Legacy | Historical Claude-era packaging metadata kept for reference. |
| `CLAUDE.md` | Compatibility doc | Older guidance retained so the migration history stays inspectable. |

## Practical editing rules

1. If you are changing workflow behavior, start in `.agents/skills/`.
2. If you are changing runtime guidance, start in `AGENTS.md` and repo-native docs.
3. If you are changing recovery or validation behavior, inspect `scripts/` and `.codex/hooks.json`.
4. If you update canonical skills and the packaged plugin should stay aligned, run `./scripts/sync-plugin-package.sh`.
5. Do not treat `plugins/autoworker-codex/` or `skills/` as the primary source of truth.

## Fast orientation

Use this path when opening the repo cold:

1. Read `README.md` for the product pitch and quick start.
2. Read `AGENTS.md` for always-on repo rules.
3. Read `docs/codex-workspace.md` for direct Codex usage.
4. Run `python3 scripts/autoworker_state.py --json --write-state` to inspect current durable state.

## Validation

When docs or repo surfaces change, these commands are the quickest confidence checks:

```bash
./scripts/verify-hooks.sh
./scripts/verify-codex-workspace.sh
./scripts/verify-autonomy-surface.sh
```
