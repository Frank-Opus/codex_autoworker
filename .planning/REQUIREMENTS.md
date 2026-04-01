# Requirements: Autoworker for Codex CLI

**Defined:** 2026-04-01
**Core Value:** A Codex CLI user can invoke Autoworker and trust that the workflow advances only with real execution evidence, never with hand-wavy "done" claims.

## v1 Requirements

Requirements for the initial Codex CLI release. Each requirement maps to exactly one roadmap phase.

### Project Surface

- [ ] **SURF-01**: Repo root contains an `AGENTS.md` that explains the Codex-first project purpose, workflow entry points, and execution rules
- [ ] **SURF-02**: The repo exposes Codex-discoverable Autoworker skills from a runnable location without requiring manual copying by the user
- [ ] **SURF-03**: The primary user documentation explains Codex-native installation/invocation and no longer depends on Claude-only commands for the happy path

### Workflow Semantics

- [ ] **FLOW-01**: The Codex version preserves explicit plan -> dispatch -> code/test -> gate -> retry semantics for non-trivial tasks
- [ ] **FLOW-02**: The Codex version preserves acceptance-tracing and evidence-based completion rules so "done" requires observed verification
- [ ] **FLOW-03**: The Codex version preserves file-backed recovery/resume behavior across interrupted or fresh Codex sessions

### Hook and Script Integration

- [ ] **HOOK-01**: Each Claude-specific lifecycle hook or reminder is either mapped to a Codex-native mechanism or explicitly replaced with a documented fallback
- [ ] **HOOK-02**: Hook or fallback behavior works from the repository root and from nested working directories without path breakage
- [ ] **HOOK-03**: Repo scripts used by the Codex workflow have a documented contract, invocation path, and verification method

### Verification and Migration Safety

- [ ] **VERF-01**: The migration includes a compatibility matrix documenting how each current Claude-specific capability translates to Codex CLI
- [ ] **VERF-02**: The migrated workflow is exercised end-to-end inside Codex CLI with evidence for planning, execution, testing/gating, and recovery behavior
- [ ] **VERF-03**: The repository includes migration notes that clearly separate preserved behavior, changed behavior, and deferred behavior

### Distribution

- [ ] **DIST-01**: The repo can be used directly as a Codex workspace without plugin packaging
- [ ] **DIST-02**: If plugin packaging is included in v1, it uses a valid Codex plugin manifest and installable layout that points at the migrated workflow assets

## v2 Requirements

### Compatibility

- **COMP-01**: Maintain an explicit compatibility layer for both Claude Code and Codex CLI from one shared source tree
- **COMP-02**: Provide automated generation of Codex and Claude variants from one canonical workflow definition

### Ecosystem

- **ECOS-01**: Publish a reusable plugin package and marketplace metadata for broader distribution
- **ECOS-02**: Add optional Codex-native helper skills for roadmap creation, migration validation, or environment checks

## Out of Scope

| Feature | Reason |
|---------|--------|
| GUI or hosted orchestration dashboard | Local Codex CLI workflow is the product target |
| Feature expansion unrelated to Codex adaptation | The current milestone is migration, not product redesign |
| Full dual-tool parity in the first milestone | Creates ambiguity and slows validation |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| SURF-01 | TBD | Pending |
| SURF-02 | TBD | Pending |
| SURF-03 | TBD | Pending |
| FLOW-01 | TBD | Pending |
| FLOW-02 | TBD | Pending |
| FLOW-03 | TBD | Pending |
| HOOK-01 | TBD | Pending |
| HOOK-02 | TBD | Pending |
| HOOK-03 | TBD | Pending |
| VERF-01 | TBD | Pending |
| VERF-02 | TBD | Pending |
| VERF-03 | TBD | Pending |
| DIST-01 | TBD | Pending |
| DIST-02 | TBD | Pending |

**Coverage:**
- v1 requirements: 14 total
- Mapped to phases: 0
- Unmapped: 14 ⚠️

---
*Requirements defined: 2026-04-01*
*Last updated: 2026-04-01 after initial definition*
