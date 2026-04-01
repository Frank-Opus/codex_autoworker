# Codex Target Architecture

## Canonical Structure

```text
.
├── AGENTS.md
├── .agents/
│   ├── skills/
│   │   ├── autoworker/
│   │   ├── deep-plan/
│   │   ├── dispatch/
│   │   ├── code/
│   │   ├── test/
│   │   ├── gate-check/
│   │   ├── checkpoint/
│   │   ├── subtask-init/
│   │   ├── subtask-plan/
│   │   ├── subtask-update/
│   │   └── sync-docs/
│   └── plugins/
│       └── marketplace.json
├── .codex/
│   ├── hooks.json
│   └── hooks/
├── docs/
│   └── migration/
├── plugins/
│   └── autoworker-codex/
├── scripts/
└── legacy/
    └── claude/          # Optional holding area for Claude-specific remnants if retained
```

## Source-of-Truth Decision

The Codex-visible skill tree under `.agents/skills/` is the canonical runtime layout for this milestone.

Rationale:
- Codex discovers repo skills from `.agents/skills/` directly.
- Avoids hidden generation steps during the first migration milestone.
- Makes docs and validation point at the same files users actually run.

## Transitional Rule

The existing top-level `skills/` directory may remain temporarily as legacy/source material only while parity work is in progress, but later phases must either:
- remove it, or
- convert it into clearly marked legacy/compatibility content.

## Hook Strategy

Use hooks only for deterministic, low-risk reminder behavior. Core workflow correctness must live in the skills and repository guidance, not in hooks.
