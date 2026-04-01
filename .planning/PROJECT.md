# Autoworker for Codex CLI

## What This Is

Autoworker for Codex CLI is a Codex-native port of the existing Autoworker workflow repo. It keeps the core value of the current project — a strict auto-loop execution workflow with quality gates — but rebuilds packaging, docs, prompts, hooks, and execution assumptions so the workflow runs correctly inside Codex CLI instead of Claude Code.

The product is for people who want a durable, file-backed coding workflow that forces plan → implement → test → gate → retry discipline in Codex CLI sessions, including fresh-session recovery and collaborative agent execution where Codex supports it.

## Core Value

A Codex CLI user can invoke Autoworker and trust that the workflow advances only with real execution evidence, never with hand-wavy "done" claims.

## Requirements

### Validated

- ✓ Existing Autoworker documents a Claude Code-first state-machine workflow with planning, gated execution, testing layers, and anti-loss scripts — existing repo baseline
- ✓ Existing Autoworker already stores core behavior in skill documents and helper scripts, making the logic portable rather than hard-coded into one app runtime — existing repo baseline
- ✓ The repo now exposes a Codex-first runtime surface through `AGENTS.md`, `.agents/skills/`, repo-local hooks, and Codex-native docs — validated by Phases 2 and 4
- ✓ The migrated workflow has parity evidence for planning, execution, gating, and resume semantics inside Codex CLI — validated by Phase 3
- ✓ Optional repo-local plugin packaging exists without replacing the canonical repo-native authoring surface — validated by Phase 4

### Active

None. The milestone goals for the Codex-first migration are complete.

### Out of Scope

- Shipping support for Claude Code and Codex CLI from the exact same primary docs in v1 — avoid diluted guidance during migration
- Building a hosted service or GUI for workflow orchestration — local Codex CLI usage is the target
- Expanding Autoworker into a generic all-agent framework — keep focus on Codex-native execution of the existing loop

## Context

- Current repo content is heavily Claude Code-oriented: README installation uses Claude plugin commands, skill frontmatter uses Claude-oriented tools and hooks, and anti-loss scripts assume Claude's `/clear` lifecycle.
- The repo is small and mostly prompt/script based, so the highest-risk work is instruction compatibility rather than application runtime code.
- Codex CLI has its own primitives: `AGENTS.md`, repo/user/project skills, approval and sandbox modes, developer-tool wrappers, and optional plugins. The migration should align to those native mechanisms rather than mimic Claude conventions mechanically.
- The migration should preserve the conceptual strengths already present in this repo: explicit state transitions, traceable verification, anti-skipping constraints, and file-backed recovery.

## Constraints

- **Platform**: Codex CLI native first — the end state must feel idiomatic in Codex, not like Claude prompts pasted into a different shell
- **Compatibility**: Preserve the existing workflow semantics where possible — users should still recognize Autoworker's plan/dispatch/test/gate loop
- **Risk**: Prompt and hook regressions are high risk — instruction changes need direct workflow verification, not just static review
- **Distribution**: The repo should be usable directly from a Codex workspace and support eventual plugin packaging if warranted

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Make Codex CLI the primary target instead of maintaining dual-primary docs from day one | Clear guidance is more important than short-term cross-tool ambiguity | Complete |
| Keep the existing state-machine and quality-gate concepts as the product core | The value of the repo is the loop discipline, not the Claude-specific surface area | Complete |
| Treat hooks, skills, packaging, and documentation as first-class migration workstreams | Most breakage risk is in workflow plumbing, not business logic | Complete |
| Keep `.agents/skills/` canonical and treat packaged plugin assets as a synced snapshot | Prevent distribution artifacts from becoming the authoring source of truth | Complete |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `$gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `$gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-01 after Codex-first migration milestone completion*
