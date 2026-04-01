# Phase 3: Workflow Parity Verification - Context

**Gathered:** 2026-04-01
**Status:** Ready for planning
**Mode:** Autonomous implementation

<domain>
## Phase Boundary

Prove with real Codex CLI runs that the migrated Autoworker still preserves planning, dispatch, verification, gating, and file-backed recovery semantics.

</domain>

<decisions>
## Implementation Decisions

- Use a tiny deterministic fixture so workflow behavior is easier to isolate than application complexity.
- Keep the proof executable via a repo-local verifier script, not only via one-off manual notes.
- Split evidence into three paths: planning-only, happy-path execution with resume, and recovery-after-failure.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- Phase 2 already proved Codex can see `AGENTS.md`, `.agents/skills/`, and the hook layer in a real `codex exec` run.
- The migrated skills already encode the plan -> dispatch -> code/test -> gate semantics that need proof.

### Integration Points
- `tests/fixtures/parity-workflow/template/` can host a small deterministic workspace for repeated parity checks.
- The Phase 3 verifier must exercise real `codex exec` sessions instead of simulating skill routing in shell only.

</code_context>

<specifics>
## Specific Ideas

- Add a reusable `scripts/verify-workflow-parity.sh` harness.
- Record the expected evidence path in `docs/migration/workflow-parity-evidence.md`.
- Use fresh workspaces per scenario so resume and recovery claims are backed by disk state.

</specifics>

<deferred>
## Deferred Ideas

- Larger multi-language fixtures beyond the tiny Python proof
- Stress-testing long-running background jobs in the same parity harness

</deferred>
