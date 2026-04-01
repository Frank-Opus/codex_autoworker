---
phase: "01"
name: "Migration Contract"
created: 2026-04-01
status: passed
---

# Phase 1: Migration Contract - Verification

## Goal-Backward Verification

**Phase Goal:** Produce the migration contract that maps current Claude-specific behavior to Codex-native mechanisms and locks the target repo structure.

## Checks

| # | Requirement | Status | Evidence |
|---|------------|--------|----------|
| 1 | Compatibility matrix exists for invocation, skill discovery, hooks, repo guidance, recovery, and packaging | Passed | `docs/migration/codex-compatibility-matrix.md` |
| 2 | Source-of-truth Codex layout decision is documented | Passed | `docs/migration/codex-target-architecture.md` |
| 3 | Workflow invariants to preserve in Codex are explicit and testable | Passed | `docs/migration/workflow-invariants.md` |

## Result

Phase 1 passes. Later phases now have a documented contract for layout, parity expectations, and migration scope.
