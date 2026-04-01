# Project Research Summary

**Project:** Autoworker for Codex CLI
**Domain:** Codex-native workflow migration for a prompt-and-script automation repo
**Researched:** 2026-04-01
**Confidence:** HIGH

## Executive Summary

This project is not a net-new product; it is a migration of an existing Claude Code-first workflow into a Codex CLI-native repository and optional plugin. Research points to a clear native surface for Codex: `AGENTS.md` for persistent repo instructions, `.agents/skills/` for local workflow skills, `.codex/hooks.json` for deterministic lifecycle scripts where useful, and optional plugin packaging only after the repo-native workflow is stable.

The recommended approach is therefore repo-native first, packaging second. The most important risk is not code complexity but behavioral drift: the migration can easily preserve filenames while losing the workflow's true value — strict dispatch, evidence-based testing, and gate-enforced completion. The roadmap should front-load compatibility mapping and structural migration, then verify end-to-end workflow behavior in Codex before polishing distribution.

## Key Findings

### Recommended Stack

Codex's official docs make the migration path fairly direct: keep repository-wide expectations in `AGENTS.md`, move runnable skills into `.agents/skills/`, use `.codex/hooks.json` only for high-value deterministic behavior, and add a plugin manifest later if broader installability matters.

**Core technologies:**
- `AGENTS.md`: persistent repository instructions — Codex loads it automatically by path
- Repo skills in `.agents/skills/`: reusable workflow logic — native local discovery path
- `.codex/hooks.json`: lifecycle validation/reminder hooks — useful but experimental
- Optional `.codex-plugin/plugin.json`: installable distribution — best after stabilization

### Expected Features

The Codex-native version must first preserve the repo's table-stakes workflow behaviors rather than invent new ones.

**Must have (table stakes):**
- Codex-discoverable workflow skills — users can actually invoke the workflow inside the repo
- Root `AGENTS.md` guidance — repository norms and workflow entry points load automatically
- Codex-first installation and invocation docs — no ambiguity about how to run the workflow
- Recovery/continuity behavior — anti-loss promises are preserved or explicitly redesigned

**Should have (competitive):**
- Strict dispatch/test/gate state machine preserved inside Codex
- File-backed resumability across sessions
- Optional future plugin packaging for broader reuse

**Defer (v2+):**
- Full dual support for Claude Code and Codex CLI
- Rich plugin/connectors surface beyond the workflow core

### Architecture Approach

The architecture should be layered: `AGENTS.md` for repo-wide policy, `.agents/skills/` for workflow behavior, `.codex/hooks.json` plus scripts for deterministic lifecycle automation, and optional plugin packaging as a separate distribution layer. This keeps local dogfooding fast while preserving a clean future path to installation via plugins.

**Major components:**
1. `AGENTS.md` — repository expectations and default workflow routing
2. `.agents/skills/` — Codex-native workflow skills
3. `.codex/hooks.json` + `scripts/` — deterministic reminders/validators/recovery helpers
4. Optional plugin package — reusable distribution once behavior stabilizes

### Critical Pitfalls

1. **Superficial porting** — map every Claude-specific behavior to a real Codex mechanism
2. **Losing workflow value** — preserve dispatch/test/gate semantics, not just file names
3. **Overusing hooks** — keep hooks minimal and deterministic because the feature is experimental
4. **Packaging too early** — validate repo-native usage before distributing

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Compatibility and target architecture
**Rationale:** The migration must start by deciding what each current Claude-specific feature becomes in Codex.
**Delivers:** Compatibility matrix, target repo structure, Codex-first migration decisions.
**Addresses:** Invocation, AGENTS, skills, hooks, docs.
**Avoids:** Superficial porting and scope drift.

### Phase 2: Core Codex surfaces
**Rationale:** Users need Codex to load instructions and discover runnable skills before deeper verification is meaningful.
**Delivers:** Root `AGENTS.md`, repo skill layout, initial docs update, hook/fallback scaffolding.
**Uses:** AGENTS layering, repo skill discovery, hook config shape.
**Implements:** Repository guidance and workflow authoring components.

### Phase 3: Workflow parity and proof
**Rationale:** Once Codex can load the workflow, the repo must prove that the Autoworker loop still behaves correctly.
**Delivers:** Verified Codex execution path for planning, dispatch, testing, gate checks, and recovery.
**Uses:** Existing workflow semantics and repo scripts.
**Implements:** Behavior-preserving migration.

### Phase 4: Packaging and polish
**Rationale:** Distribution should happen only after the local workflow is stable.
**Delivers:** Optional plugin package, marketplace metadata, polished docs, migration notes.
**Uses:** Stable repo-native workflow assets.
**Implements:** Distribution layer.

### Phase Ordering Rationale

- AGENTS and skill discovery are prerequisites for meaningful Codex dogfooding.
- Hook migration should remain bounded and support, not define, the workflow.
- End-to-end workflow verification is the true release gate for this migration.
- Packaging belongs last because it multiplies maintenance cost if the core is still moving.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2:** Hook behavior details on the exact target Codex environments
- **Phase 4:** Plugin packaging and marketplace conventions if distribution is required immediately

Phases with standard patterns (skip research-phase):
- **Phase 1:** Compatibility matrix and target layout are mostly internal product decisions

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Official Codex docs cover AGENTS, skills, hooks, and plugin packaging directly |
| Features | HIGH | Requirements derive from official platform surfaces plus the repo's existing value proposition |
| Architecture | HIGH | Layered repo-native first architecture follows official discovery/distribution models |
| Pitfalls | HIGH | Risks are strongly implied by the repo's current Claude-centric structure and Codex's different primitives |

**Overall confidence:** HIGH

### Gaps to Address

- Hook behavior should be validated on the exact Codex environments the repo targets.
- Decide whether the source-of-truth skill tree stays in `skills/` with generation or moves entirely into `.agents/skills/`.
- Decide when, if ever, dual-tool compatibility is worth adding after the Codex migration lands.

## Sources

### Primary (HIGH confidence)
- https://developers.openai.com/codex/guides/agents-md — instruction layering and precedence
- https://developers.openai.com/codex/skills — skill authoring, discovery paths, and plugin relationship
- https://developers.openai.com/codex/hooks — repo hook locations, feature flag, matcher groups
- https://developers.openai.com/codex/plugins/build — plugin manifest and repo marketplace structure

### Secondary (MEDIUM confidence)
- https://developers.openai.com/codex/cli/slash-commands — useful built-in commands for dogfooding and setup
- Current Autoworker repo docs/scripts — baseline behavior and migration scope

---
*Research completed: 2026-04-01*
*Ready for roadmap: yes*
