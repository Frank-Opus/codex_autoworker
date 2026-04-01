# Pitfalls Research

**Domain:** Codex CLI workflow migration pitfalls
**Researched:** 2026-04-01
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Superficial porting of Claude-specific behaviors

**What goes wrong:** The repo looks renamed for Codex, but invocation, hooks, or skill discovery still depend on Claude-only semantics.

**Why it happens:** Teams rename files and commands before mapping actual runtime behaviors.

**How to avoid:** Build a compatibility matrix for each current feature: invocation, guidance loading, hooks, state persistence, and distribution.

**Warning signs:** README still centers Claude plugin commands; skills remain outside Codex discovery paths; hook behavior exists only in prose.

**Phase to address:** Phase 1

---

### Pitfall 2: Losing the workflow's core value during migration

**What goes wrong:** The migration produces Codex-native files, but the state-machine discipline, verification depth, and gate semantics get watered down.

**Why it happens:** Migration focuses on surface compatibility instead of behavioral parity.

**How to avoid:** Treat dispatch, L1-L4 verification, gate logic, and recovery guarantees as must-preserve contracts.

**Warning signs:** Requirements focus on file moves and docs, but not on proof of end-to-end workflow behavior.

**Phase to address:** Phase 1 and Phase 3

---

### Pitfall 3: Overcommitting to experimental hooks

**What goes wrong:** The migrated workflow becomes fragile because too much behavior depends on hooks that may vary by environment.

**Why it happens:** Hooks feel like a direct replacement for Claude lifecycle integration.

**How to avoid:** Keep hook usage minimal, deterministic, and optional; provide prompt or script fallbacks.

**Warning signs:** Critical workflow paths cannot function without hooks; local testing differs by platform.

**Phase to address:** Phase 2

---

### Pitfall 4: Packaging too early

**What goes wrong:** A plugin is published or structured too early, then has to be repeatedly broken as the repo-native workflow evolves.

**Why it happens:** Distribution polish feels like progress.

**How to avoid:** Validate repo-native skill usage first, then package the stable surface.

**Warning signs:** Plugin manifest exists before local invocation is proven; docs describe install flows no one has tested.

**Phase to address:** Phase 4

---

### Pitfall 5: Ambiguous migration scope

**What goes wrong:** Work expands from “Codex-native port” into a broad redesign of the workflow.

**Why it happens:** Prompt repositories tempt opportunistic rewrites.

**How to avoid:** Keep scope tied to Codex adaptation, preserving the existing product value and deferring broader redesigns.

**Warning signs:** New roadmap items do not map back to Codex compatibility or workflow trust.

**Phase to address:** Phase 1

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Keep old `skills/` tree only and manually copy into Codex paths later | Faster first draft | Drift between source and runnable skill layout | Acceptable only briefly if a generation step is defined immediately |
| Replace hooks with README notes only | Faster migration | Recovery behavior becomes user-dependent and inconsistent | Acceptable only if hooks prove unusable and the fallback is explicit |
| Preserve dual docs indefinitely | Less short-term churn | Perpetual confusion and verification burden | Rarely acceptable |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| `AGENTS.md` loading | Assuming one file anywhere is enough | Place root `AGENTS.md` intentionally and use overrides only where necessary |
| Skill discovery | Leaving skills in non-discoverable directories | Put runnable skills under `.agents/skills/` or package them as a plugin |
| Hook scripts | Using relative paths that break from subdirectories | Resolve hook commands from git root where possible |
| Plugin packaging | Mixing plugin manifest and runtime files arbitrarily | Keep only `plugin.json` in `.codex-plugin/`, with skills/assets at plugin root |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Excessive hook fan-out | Slow or noisy turns | Keep only high-signal hook handlers | Breaks quickly in active repos |
| Monolithic skill instructions | Hard-to-trigger or conflicting behavior | Split into focused repo skills with clear descriptions | Breaks as workflow variants grow |
| Overly broad AGENTS guidance | Codex follows stale or generic rules | Keep AGENTS concise and route specifics to skills | Breaks as repo scope changes |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Blindly porting shell hook commands | Unreviewed command execution | Keep hooks deterministic, reviewed, and repo-root-scoped |
| Assuming approvals/sandboxing match Claude behavior | Unexpected command failures or unsafe assumptions | Design docs and skills around Codex approval/sandbox semantics |
| Encouraging networked automation by default | Unnecessary risk in local workflows | Make network use explicit and bounded |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Keeping `/autoworker` as the only mental model | Codex users don't know how to invoke the workflow | Document `$autoworker`, repo skills, AGENTS guidance, and optional plugin install |
| Hiding migration limitations | Users lose trust when behavior differs | Document what is preserved, changed, and deferred |
| Overloading README with both legacy and target paths | Users miss the happy path | Make Codex-first path primary and legacy notes secondary |

## "Looks Done But Isn't" Checklist

- [ ] **Skill migration:** Skills are in a Codex-discoverable location and trigger correctly, not just copied
- [ ] **Hook migration:** Hook behavior is executed in Codex, not only documented
- [ ] **Docs migration:** Invocation examples match Codex behavior that was actually tested
- [ ] **Workflow parity:** Dispatch/test/gate loop is proven, not merely claimed
- [ ] **Packaging:** Plugin packaging is installable locally before being called complete

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Superficial porting | MEDIUM | Build a feature-by-feature compatibility matrix, rewrite docs and layout to match real Codex mechanisms |
| Lost workflow value | HIGH | Re-anchor requirements to state-machine semantics and add explicit workflow verification |
| Hook brittleness | MEDIUM | Reduce hooks to essentials and add prompt/script fallback paths |
| Early packaging | LOW | Keep plugin optional, revert to repo-native dogfooding, then repackage later |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Superficial porting | Phase 1 | Compatibility matrix and target layout approved |
| Lost workflow value | Phase 3 | End-to-end skill behavior verified in Codex |
| Hook brittleness | Phase 2 | Hook or fallback path tested from repo root and subdirectory contexts |
| Early packaging | Phase 4 | Local repo workflow validated before plugin packaging |

## Sources

- https://developers.openai.com/codex/guides/agents-md
- https://developers.openai.com/codex/skills
- https://developers.openai.com/codex/hooks
- https://developers.openai.com/codex/plugins/build
- Current repository behavior and migration risks inferred from `README.md`, `skills/`, and `scripts/`

---
*Pitfalls research for: Codex-native Autoworker migration*
*Researched: 2026-04-01*
