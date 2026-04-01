# Feature Research

**Domain:** Codex CLI-native workflow migration for an autonomous coding skill package
**Researched:** 2026-04-01
**Confidence:** HIGH

## Feature Landscape

### Table Stakes (Users Expect These)

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Repo-local skill discovery under `.agents/skills/` | Codex users expect reusable workflow logic to be invocable as skills | MEDIUM | Core migration target for current `skills/` content |
| Repository `AGENTS.md` guidance | Codex users expect always-on repository instructions to load automatically | LOW | Needed for baseline execution and workflow enforcement |
| Clear installation and invocation docs | Users need to know whether to use repo-local skills, plugins, or both | MEDIUM | Current README is Claude-specific and must be rewritten |
| Hook-based or equivalent recovery reminders | The existing workflow promises anti-loss and continuity behavior | MEDIUM | Must be translated carefully because Codex hooks are experimental |
| Codex-native verification path | Users expect a workflow to explain how it uses approvals, tools, and testing in Codex | MEDIUM | Must align prompts with actual Codex tool surfaces |

### Differentiators (Competitive Advantage)

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Strict dispatch/test/gate state machine retained in Codex | Keeps the repo's strongest differentiator instead of becoming generic promptware | HIGH | Needs prompt and artifact redesign, not just file moves |
| File-backed recovery and resumability | Gives users confidence during long autonomous runs and fresh sessions | MEDIUM | Strong fit for AGENTS + skills + hooks + state docs |
| Optional plugin packaging after repo-native stabilization | Makes the workflow easy to distribute once the local version is proven | MEDIUM | Best as a later milestone, not day-one blocker |
| Codex-specific collaboration support | Lets the workflow take advantage of Codex agents, approvals, and sandbox controls where appropriate | MEDIUM | Should be explicitly bounded to what Codex actually supports |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Perfect Claude/Codex dual parity in the first milestone | Feels efficient to support both at once | Doubles instruction complexity and makes verification ambiguous | Ship Codex-first, then decide whether to add a compatibility layer |
| Over-automated hooks for every lifecycle event | Feels like feature completeness | Codex hooks are experimental and can become brittle or noisy | Use only the highest-value hook points, keep prompt fallbacks |
| Plugin packaging before repo-native validation | Feels like a polished launch story | Can freeze the wrong structure before behavior is proven | First make repo-local skills and AGENTS work cleanly |

## Feature Dependencies

```text
Codex-native docs
    └──requires──> AGENTS.md baseline
                         └──supports──> skill invocation clarity

Repo skill migration
    └──requires──> layout decision (.agents/skills vs generated output)
                         └──enables──> dogfood testing inside Codex

Hook migration ──depends on──> validated recovery behavior
Plugin packaging ──depends on──> stable repo-native skills
```

### Dependency Notes

- **Docs require AGENTS baseline:** Users need an always-on repository contract before invoking skills safely.
- **Skill migration requires layout decision:** The repo needs one authoritative Codex-visible skill location.
- **Plugin packaging depends on stable skills:** Packaging unstable workflows just multiplies migration cost.

## MVP Definition

### Launch With (v1)

- [ ] Codex-first README and migration guidance — users can install, invoke, and reason about the workflow in Codex
- [ ] Repo-visible skills and AGENTS.md — Codex can discover the workflow without manual copying
- [ ] Verified replacement for Claude-specific hooks/instructions where essential — anti-loss and continuity are preserved or intentionally redesigned
- [ ] Maintained state-machine semantics for planning, dispatching, testing, and gating — core Autoworker value survives migration

### Add After Validation (v1.x)

- [ ] Optional plugin packaging and repo marketplace entry — once local usage is stable
- [ ] Additional Codex-native helper skills or subagent patterns — once the base workflow is trustworthy

### Future Consideration (v2+)

- [ ] Cross-tool compatibility layer for Claude Code and Codex CLI — only if demand justifies maintenance cost
- [ ] Richer app/connectors/MCP bundling — useful after core workflow adoption

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Repo-visible Codex skills | HIGH | MEDIUM | P1 |
| AGENTS.md project guidance | HIGH | LOW | P1 |
| Codex-first docs rewrite | HIGH | MEDIUM | P1 |
| Hook migration/replacement | HIGH | MEDIUM | P1 |
| Plugin packaging | MEDIUM | MEDIUM | P2 |
| Dual-tool compatibility | MEDIUM | HIGH | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

## Competitor Feature Analysis

| Feature | Current Autoworker | Codex-native expectation | Our Approach |
|---------|--------------------|--------------------------|--------------|
| Workflow invocation | Claude plugin command `/autoworker` | Skill mention, AGENTS guidance, optional plugin install | Shift to Codex skills first, with plugin packaging optional |
| Persistent repo guidance | Skill text plus repo docs | `AGENTS.md` layered by path | Generate and maintain AGENTS.md |
| Lifecycle reminders | Claude hook frontmatter + shell scripts | `.codex/hooks.json` + scripts, or prompt fallback | Migrate only the high-value pieces |
| Distribution | Claude plugin marketplace flow | Repo skills or Codex plugin marketplace | Start repo-native, package later |

## Sources

- https://developers.openai.com/codex/skills
- https://developers.openai.com/codex/guides/agents-md
- https://developers.openai.com/codex/hooks
- https://developers.openai.com/codex/plugins/build
- https://developers.openai.com/codex/cli/slash-commands
- Current repo docs and scripts

---
*Feature research for: Codex-native Autoworker migration*
*Researched: 2026-04-01*
