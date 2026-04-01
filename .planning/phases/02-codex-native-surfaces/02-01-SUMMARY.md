---
phase: 02-codex-native-surfaces
plan: 01
subsystem: codex-surface
tags: [codex, guidance, docs]
requires: []
provides:
  - Root Codex entry points documented
affects: [phase-03, phase-04]
tech-stack:
  added: []
  patterns: [repo-native Codex entry points]
key-files:
  created: [docs/codex-workspace.md]
  modified: [AGENTS.md]
key-decisions:
  - "Document $autoworker, $deep-plan, $subtask-init, and $dispatch as the primary entry points"
patterns-established:
  - "Keep AGENTS concise and move detailed workflow logic into skills"
requirements-completed: [SURF-01]
duration: 8min
completed: 2026-04-01
---

# Phase 2 Plan 01 Summary

**Repo guidance and direct-workspace entry points are now Codex-first**

## Accomplishments
- Updated `AGENTS.md` with explicit Autoworker entry points and validation commands
- Added `docs/codex-workspace.md` for direct Codex workspace usage

## Decisions Made
- Repo-native usage remains the primary happy path ahead of packaging

## Deviations from Plan
None.

## Issues Encountered
None.

## Next Phase Readiness
The workspace guidance is ready for skill and hook validation.
