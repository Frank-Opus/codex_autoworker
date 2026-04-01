# Architecture Research

**Domain:** Codex-native workflow package architecture
**Researched:** 2026-04-01
**Confidence:** HIGH

## Standard Architecture

### System Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                     Repository Guidance                     │
├─────────────────────────────────────────────────────────────┤
│  AGENTS.md  -> always-on repo rules and workflow entry     │
├─────────────────────────────────────────────────────────────┤
│                     Workflow Authoring                      │
├─────────────────────────────────────────────────────────────┤
│  .agents/skills/<skill>/SKILL.md -> task workflows         │
│  commands/docs/examples -> user-facing invocation help     │
├─────────────────────────────────────────────────────────────┤
│                   Deterministic Automation                  │
├─────────────────────────────────────────────────────────────┤
│  .codex/hooks.json -> lifecycle hooks                      │
│  scripts/ -> shell/python/node helpers                     │
├─────────────────────────────────────────────────────────────┤
│                    Distribution Layer                       │
├─────────────────────────────────────────────────────────────┤
│  .codex-plugin/plugin.json -> optional installable bundle  │
│  .agents/plugins/marketplace.json -> optional local market │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| `AGENTS.md` | Establish repo-wide expectations and workflow entry points | Root-level Markdown instructions loaded automatically by Codex |
| Repo skills | Hold reusable workflow logic and trigger descriptions | `.agents/skills/<name>/SKILL.md` with focused instructions |
| Hook layer | Run deterministic lifecycle scripts where supported | `.codex/hooks.json` plus shell/python/node commands |
| Scripts/helpers | Persist state, validate assumptions, support migrations | `scripts/` utilities invoked manually or from hooks |
| Optional plugin package | Distribute workflow beyond one repo | `.codex-plugin/plugin.json` with packaged `skills/` |

## Recommended Project Structure

```text
.
├── AGENTS.md                    # Repo-wide Codex guidance
├── .agents/
│   ├── skills/
│   │   └── autoworker/          # Codex-discoverable workflow skills
│   └── plugins/
│       └── marketplace.json     # Optional local plugin catalog
├── .codex/
│   └── hooks.json               # Optional repo-local hook configuration
├── plugins/
│   └── autoworker/              # Optional packaged distribution
├── scripts/                     # Hook handlers, migration helpers, validators
├── docs/                        # Migration notes, user guides, compatibility docs
└── legacy/ or source/           # Optional source materials retained during migration
```

### Structure Rationale

- **`AGENTS.md`:** Always-on instruction surface for repository norms and workflow routing.
- **`.agents/skills/`:** Official repo-local discovery path, so the workflow works directly in the repository.
- **`.codex/hooks.json`:** Native hook configuration point instead of embedding hook definitions in skill frontmatter.
- **`plugins/`:** Keeps installable packaging optional and separate from local authoring.
- **`docs/`:** Prevents README overload during migration.

## Architectural Patterns

### Pattern 1: Repo-native first, plugin second

**What:** Author and validate the workflow as repo-local skills before packaging.
**When to use:** Early migration, active iteration, or when semantics are still changing.
**Trade-offs:** Slight duplication later if you package a plugin, but much faster iteration.

### Pattern 2: Thin AGENTS, rich skills

**What:** Keep `AGENTS.md` focused on always-on rules and route detailed task behavior into skills.
**When to use:** Repos with multiple workflows or evolving task-specific logic.
**Trade-offs:** Users must invoke or trigger the right skill, but instructions stay maintainable.

### Pattern 3: Hooks as guardrails, not primary logic

**What:** Use hooks for deterministic reminders/validators, not to replace core workflow semantics.
**When to use:** Anti-loss reminders, policy checks, deterministic post-tool validation.
**Trade-offs:** Less magic, more reliability; avoids overfitting to experimental hook behavior.

## Data Flow

### Request Flow

```text
User request
    ↓
AGENTS.md guidance
    ↓
Relevant skill selected
    ↓
Skill reads/writes repo artifacts
    ↓
Optional hook scripts validate or persist state
    ↓
User-visible result and repo artifacts
```

### State Management

```text
Planning docs / state files
    ↓
Skill execution reads current state
    ↓
Scripts or hooks update reminders / metadata
    ↓
Next session resumes from repo state, not memory
```

### Key Data Flows

1. **Invocation flow:** User enters Codex in repo -> AGENTS loads -> skill is invoked or implicitly matched -> workflow runs.
2. **Recovery flow:** Hook or script writes/preserves continuity info -> next Codex session reads repo state -> user resumes safely.
3. **Distribution flow:** Stable repo skills -> optional plugin manifest -> optional marketplace entry -> installable package.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| Single repo | Root `AGENTS.md` + root `.agents/skills/` is enough |
| Multi-module repo | Add nested `.agents/skills/` or `AGENTS.override.md` near specialized areas |
| Multi-repo distribution | Package a plugin and optionally publish a marketplace entry |

### Scaling Priorities

1. **First bottleneck:** Instruction drift between docs and skills — solve with one authoritative Codex-native source layout.
2. **Second bottleneck:** Hook brittleness across environments — keep hook logic optional and deterministic.

## Anti-Patterns

### Anti-Pattern 1: Frontmatter compatibility theater

**What people do:** Keep Claude-oriented frontmatter and assume Codex will interpret it the same way.
**Why it's wrong:** Codex has different discovery and hook mechanisms.
**Do this instead:** Map each Claude-specific behavior to a real Codex mechanism or explicitly remove it.

### Anti-Pattern 2: Packaging before dogfooding

**What people do:** Build plugin structure first and only later test local usability.
**Why it's wrong:** Distribution freezes poor assumptions.
**Do this instead:** Make repo-local Codex usage smooth before packaging.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| Codex CLI instruction loader | `AGENTS.md` + skill discovery | Core integration surface |
| Codex hook runtime | `.codex/hooks.json` | Experimental; validate on target environments |
| Plugin marketplace | Repo-local or personal marketplace JSON | Optional packaging path |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| `AGENTS.md` ↔ skills | Instruction routing | AGENTS sets defaults; skills carry workflow detail |
| skills ↔ scripts | Command execution | Scripts should stay deterministic and repo-root-safe |
| repo-native workflow ↔ plugin package | Copy/package boundary | Keep clear ownership to avoid drift |

## Sources

- https://developers.openai.com/codex/guides/agents-md
- https://developers.openai.com/codex/skills
- https://developers.openai.com/codex/hooks
- https://developers.openai.com/codex/plugins/build
- Current repository structure and Autoworker docs

---
*Architecture research for: Codex-native Autoworker migration*
*Researched: 2026-04-01*
