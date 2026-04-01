# Codex Migration Notes

This document separates what Autoworker preserved, what changed intentionally for Codex CLI, and what remains deferred beyond the first Codex-first milestone.

## Preserved behavior

| Area | Preserved behavior | Where to see it |
|------|--------------------|-----------------|
| Execution chain | Plan -> dispatch -> code/test -> gate -> retry remains the workflow core | `.agents/skills/`, `docs/migration/workflow-invariants.md` |
| Evidence discipline | "Done" still requires observed verification evidence, not prompt-only claims | `.agents/skills/gate-check/SKILL.md`, `docs/migration/workflow-parity-evidence.md` |
| File-backed resume | Active subtask state still lives in `subtask_*.md` and can be resumed by `$dispatch` | `.agents/skills/dispatch/SKILL.md`, `docs/codex-workspace.md` |
| Hooks as support only | Hooks assist reminders, but correctness still lives in the workflow files and skills | `docs/migration/codex-hooks-and-fallbacks.md` |

## Changed behavior

| Area | Claude-era behavior | Codex-first behavior | Reason |
|------|---------------------|----------------------|--------|
| Primary docs | README and happy path were Claude/plugin-first | README and workspace docs are now repo-native Codex-first | Reduce ambiguity for Codex users |
| Skill location | Top-level `skills/` tree was the main visible workflow surface | `.agents/skills/` is the canonical runtime tree | Match Codex repo skill discovery |
| Recovery trigger | `/clear` was a first-class lifecycle assumption | `SessionStart` guidance plus `$dispatch` file-state resume replaces `/clear`-specific behavior | Codex does not share Claude's `/clear` lifecycle |
| Packaging | Claude plugin marketplace commands were the install story | Repo-native usage is primary; packaged Codex plugin is optional | Validate local workspace behavior before distribution |
| Hook pathing | Claude shell snippets assumed Claude plugin-relative paths | Codex hooks are repo-local Python helpers with explicit validation scripts | Make path behavior deterministic from repo root and nested dirs |

## Deferred behavior

| Deferred item | Why deferred |
|---------------|--------------|
| Dual-primary Claude + Codex documentation | Would dilute the Codex-first migration and complicate validation |
| Automated generation from one canonical workflow source tree | Valuable for v2, but not required to prove Codex-native viability |
| Broader marketplace publishing and ecosystem polish | Secondary to getting the repo-native workflow trustworthy first |
| Large, multi-language parity fixtures | The tiny Python fixture is enough to validate loop semantics in v1 |

## Practical guidance

- For real work inside this repo, use `.agents/skills/` and the repo root `AGENTS.md` as the source of truth.
- Treat `plugins/autoworker-codex/` as a distributable snapshot, not the authoring location.
- If repo-native and packaged assets ever drift, sync from canonical runtime files first, then re-run the packaging validators.
