# Phase 2: Codex-Native Surfaces - Context

**Gathered:** 2026-04-01
**Status:** Ready for planning
**Mode:** Autonomous implementation

<domain>
## Phase Boundary

Land the repo-level surfaces that make Autoworker usable directly inside Codex CLI: discoverable skills, repo-local hooks, and direct workspace validation.

</domain>

<decisions>
## Implementation Decisions

- `.agents/skills/` is the canonical Codex-visible skill tree for this milestone.
- `AGENTS.md` stays the primary repo-wide guidance surface.
- Hooks remain advisory; the workflow must still work when hooks are disabled.
- Path safety must be verified from nested directories, not only repo root.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- Existing `skills/` content can seed the Codex skill tree.
- Existing shell scripts capture anti-loss intent and should inform the Codex hook replacements.
- Existing migration docs already define the target layout and fallback strategy.

### Integration Points
- `.codex/hooks.json` must point at repo-local helpers safely from nested working directories.
- Validation should include at least one real `codex exec` workspace check.

</code_context>

<specifics>
## Specific Ideas

- Copy the current workflow skills into `.agents/skills/` and adapt the naming surface for Codex.
- Replace Claude hook frontmatter with repo-local Codex hooks.
- Add scripts that verify both hook behavior and direct workspace visibility.

</specifics>

<deferred>
## Deferred Ideas

- Full cleanup of every Claude-specific phrase in legacy skill text
- Plugin packaging metadata polish beyond local workspace readiness

</deferred>
