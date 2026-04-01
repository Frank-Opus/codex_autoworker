# Codex Compatibility Matrix

## Goal

Map every high-value Claude Code-specific Autoworker behavior to its Codex CLI equivalent, fallback, or deferred state.

| Capability | Current Claude Implementation | Codex Target | Status | Notes |
|------------|-------------------------------|--------------|--------|-------|
| Repo-wide always-on guidance | Skill text plus README | `AGENTS.md` | Planned | Codex-native repo instruction surface |
| Skill discovery | Claude plugin/skill system | `.agents/skills/` | Planned | Repo-native, versioned, discoverable |
| Marketplace/plugin install path | Claude plugin marketplace commands | Optional Codex plugin package | Planned | Secondary to repo-native usage |
| Stop reminder hook | Skill frontmatter `Stop` hook calling `scripts/state-persist.sh` | `.codex/hooks.json` stop handler or documented fallback | Planned | Keep deterministic and lightweight |
| Session recovery hook | Skill frontmatter `SessionStart` hook on `clear` | Codex session-start hook/fallback reminder | Planned | No 1:1 `/clear` semantic in Codex |
| Execution chain contract | Skill docs + README | Migrated Codex skill docs | Planned | Core invariant to preserve |
| Anti-loss persistence guidance | Shell scripts + prompt rules | Hook plus AGENTS/skill guidance | Planned | Preserve file-backed recovery intent |
| Plan-first path | `deep-plan` in Claude mode | Codex repo skills / planning docs | Planned | Same behavior, different invocation surface |
| Direct execution path | `/autoworker` command | Codex skill invocation / repo workflow entry | Planned | Must be clearly documented |
| Quality gate loop | `dispatch` -> `code/test/gate-check/update` | Same logic in Codex-visible skills | Planned | Core product identity |
| Legacy Claude behavior | Native | Deferred compatibility note | Deferred | Not a v1 success gate |

## Migration Rules

1. No Claude-specific behavior should remain undocumented once a Codex path exists.
2. If a Codex-native mechanism is not reliable enough, the repo must include an explicit fallback.
3. Later phases may change file layout, but not these contracts without updating this matrix.
