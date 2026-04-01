# Phase 4: Packaging and Docs Polish - Context

**Gathered:** 2026-04-01
**Status:** Ready for planning
**Mode:** Autonomous implementation

<domain>
## Phase Boundary

Finish the migration with Codex-first user docs, explicit preserved/changed/deferred migration notes, and an optional installable plugin snapshot that reflects the canonical runtime assets.

</domain>

<decisions>
## Implementation Decisions

- Rewrite the README around repo-native Codex usage first.
- Keep packaged plugin assets explicitly secondary to the canonical `.agents/skills/` tree.
- Add package sync and verification scripts so the plugin snapshot cannot silently drift.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `docs/codex-workspace.md` already documents the repo-native happy path.
- `docs/migration/` already contains the compatibility matrix, hook notes, and parity evidence.
- `docs/migration/codex-target-architecture.md` already reserved `plugins/autoworker-codex/` and `.agents/plugins/marketplace.json`.

### Integration Points
- `README.md` must become the primary user-facing Codex entry point.
- Plugin packaging must stay synchronized with `.agents/skills/`.

</code_context>

<specifics>
## Specific Ideas

- Rewrite `README.md` to be fully Codex-first.
- Add a migration notes document with preserved, changed, and deferred sections.
- Package a repo-local `autoworker-codex` plugin snapshot and validate it with repo scripts.

</specifics>

<deferred>
## Deferred Ideas

- Publishing the package outside the repo-local marketplace
- Plugin visual assets and broader store polish

</deferred>
