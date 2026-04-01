# Phase 1: Migration Contract - Context

**Gathered:** 2026-04-01
**Status:** Ready for planning
**Mode:** Auto-generated (infrastructure phase)

<domain>
## Phase Boundary

Define how the current Claude Code-oriented Autoworker repository maps to Codex CLI, lock the target repository structure, and make the migration invariants explicit enough that later implementation phases can execute without reopening the contract.

</domain>

<decisions>
## Implementation Decisions

### Migration Strategy
- Codex CLI is the primary target surface for this milestone.
- The migration preserves the Autoworker loop semantics rather than maximizing short-term Claude compatibility.
- Repo-native Codex usage must work before plugin packaging is treated as complete.

### Scope Boundaries
- This phase defines compatibility, structure, and invariants only.
- This phase does not yet claim end-to-end parity or finished packaging.
- Dual-tool compatibility is deferred unless later phases prove it is worth the maintenance cost.

### the agent's Discretion
- The agent may choose exact document locations and artifact names as long as they remain discoverable and consistent with the roadmap.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- Existing `skills/` tree already contains the workflow logic to port.
- Existing `scripts/state-persist.sh` and `scripts/state-recover.sh` capture the anti-loss intent.
- Existing README documents the current state-machine model and quality-gate loop.

### Established Patterns
- Workflow behavior is documented in Markdown-first skill files.
- Shell scripts are used for lightweight lifecycle support.
- The repo is small and document-driven, so structural clarity matters more than runtime abstraction.

### Integration Points
- Future Codex-native skills will need to point at the migrated workflow content.
- Future hook behavior must integrate with existing scripts or Codex-native replacements.
- Docs, skills, and hook configuration must remain consistent.

</code_context>

<specifics>
## Specific Ideas

- Preserve the plan/dispatch/test/gate loop as the product identity.
- Prefer `.agents/skills/` + `AGENTS.md` + `.codex/hooks.json` as the target Codex architecture.

</specifics>

<deferred>
## Deferred Ideas

- Dual Claude/Codex compatibility layer
- Marketplace publication beyond local/plugin packaging readiness

</deferred>
