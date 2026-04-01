# Codex Hooks and Fallbacks

This document records how the Claude-oriented Autoworker lifecycle behavior maps to Codex-native hooks and where behavior intentionally changes.

## Mapping Table

| Legacy behavior | Codex v1 mapping | Status | Verification |
|---|---|---|---|
| Stop reminder to persist discussion conclusions | Repo-local `Stop` hook in `.codex/hooks.json` calling `.codex/hooks/stop_persist_state.py` | Migrated | `scripts/verify-hooks.sh` |
| `/clear` recovery reminder | `SessionStart` hook for `startup|resume` calling `.codex/hooks/session_start_context.py` | Replaced | `scripts/verify-hooks.sh` |
| Path stability from nested directories | Git-root-based hook commands using `$(git rev-parse --show-toplevel)` | Migrated | `scripts/verify-hooks.sh` |
| Repo-native usability without hooks | `AGENTS.md` plus `.agents/skills/` remain the primary workflow surface | Preserved | `scripts/verify-codex-workspace.sh` |

## Why `/clear` Becomes a Fallback

Codex does not expose the same `/clear`-matched lifecycle event used by the Claude version. The closest reliable Codex-native surface is `SessionStart` with `startup|resume` sources.

That means the migrated repo intentionally changes behavior:

- it reminds on every startup or resume instead of only after `/clear`
- it treats file-backed state as the source of truth for recovery
- it keeps the core recovery contract in skills and docs rather than relying on hooks alone

## Hook Contract

### SessionStart

- Input: Codex hook JSON on stdin
- Output: JSON with `hookSpecificOutput.additionalContext`
- Purpose: tell Codex where Autoworker state lives and when to use `$dispatch` vs `$subtask-init`

### Stop

- Input: Codex hook JSON on stdin
- Output: JSON with `continue: true` and optional `systemMessage`
- Purpose: remind Codex to persist evidence and decisions when an active subtask exists without a recorded pass gate

## Legacy Scripts

The previous `scripts/state-persist.sh` and `scripts/state-recover.sh` remain in the repo as migration references. They are no longer the primary Codex runtime path.
