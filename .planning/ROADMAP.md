# Roadmap: Autoworker for Codex CLI

## Overview

This roadmap ports the existing Autoworker repository from a Claude Code-first workflow package to a Codex CLI-native workflow. The sequence intentionally starts with migration truth and target architecture, then lands the Codex-native repo surfaces, then proves the loop still works inside Codex, and only then packages/polishes the result for wider reuse.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Migration Contract** - Define the compatibility matrix, target architecture, and non-negotiable workflow invariants (completed 2026-04-01)
- [x] **Phase 2: Codex-Native Surfaces** - Land AGENTS, Codex skill layout, hook/fallback scaffolding, and direct-workspace usability (completed 2026-04-01)
- [x] **Phase 3: Workflow Parity Verification** - Prove the Autoworker loop still behaves correctly inside Codex CLI (completed 2026-04-01)
- [x] **Phase 4: Packaging and Docs Polish** - Finalize docs, migration notes, and optional plugin distribution assets (completed 2026-04-01)

## Phase Details

### Phase 1: Migration Contract
**Goal**: Produce the migration contract that maps current Claude-specific behavior to Codex-native mechanisms and locks the target repo structure.
**Depends on**: Nothing (first phase)
**Requirements**: [VERF-01]
**Success Criteria** (what must be TRUE):
  1. A compatibility matrix exists for invocation, skill discovery, hooks, repo guidance, recovery, and packaging
  2. The source-of-truth Codex layout decision is documented and approved
  3. The workflow invariants to preserve in Codex are explicit and testable
**Plans**: 3 plans

Plans:
- [x] 01-01: Audit current Claude-specific touchpoints and write compatibility matrix
- [x] 01-02: Decide repo layout and migration boundaries for skills, hooks, and docs
- [x] 01-03: Define preserved workflow invariants and verification contract

### Phase 2: Codex-Native Surfaces
**Goal**: Make the repository usable as a Codex workspace with repo-level guidance, discoverable skills, and working recovery/hook scaffolding.
**Depends on**: Phase 1
**Requirements**: [SURF-01, SURF-02, HOOK-01, HOOK-02, HOOK-03, DIST-01]
**Success Criteria** (what must be TRUE):
  1. Codex loads a root `AGENTS.md` that correctly explains the project and workflow entry points
  2. The migrated workflow skills live in a Codex-discoverable location and can be invoked in-repo
  3. Each essential Claude lifecycle behavior has a Codex-native implementation or documented fallback
  4. Hook/script paths work from repo root and nested directories
  5. The repo can be used directly in Codex without plugin packaging
**Plans**: 4 plans

Plans:
- [x] 02-01: Create AGENTS baseline and Codex-first workflow routing guidance
- [x] 02-02: Migrate or generate Codex-discoverable skill layout
- [x] 02-03: Implement hook or fallback recovery/reminder layer for Codex
- [x] 02-04: Validate direct Codex workspace usability and path safety

### Phase 3: Workflow Parity Verification
**Goal**: Verify that planning, dispatch, verification, gating, and recovery still work with real evidence in Codex CLI.
**Depends on**: Phase 2
**Requirements**: [FLOW-01, FLOW-02, FLOW-03, VERF-02]
**Success Criteria** (what must be TRUE):
  1. A non-trivial Codex run follows the intended plan -> dispatch -> code/test -> gate flow
  2. Completion claims are backed by observed verification evidence, not prompt-only assertions
  3. Recovery/resume behavior works across interrupted or fresh Codex sessions
  4. Gaps found during testing are fed back into the workflow instead of bypassed
**Plans**: 4 plans

Plans:
- [x] 03-01: Build Codex-native execution test fixture or harness
- [x] 03-02: Exercise planning, dispatch, and verification path end-to-end
- [x] 03-03: Exercise failure/retry/recovery path end-to-end
- [x] 03-04: Capture parity evidence and fix any workflow regressions

### Phase 4: Packaging and Docs Polish
**Goal**: Publish a clean Codex-first user experience with migration notes and optional plugin packaging.
**Depends on**: Phase 3
**Requirements**: [SURF-03, VERF-03, DIST-02]
**Success Criteria** (what must be TRUE):
  1. README and supporting docs describe a clear Codex-first happy path
  2. Migration notes clearly separate preserved, changed, and deferred behavior
  3. If included, plugin packaging installs against the migrated workflow assets successfully
**Plans**: 3 plans

Plans:
- [x] 04-01: Rewrite README and supporting docs for Codex-first usage
- [x] 04-02: Add explicit migration notes and compatibility guidance
- [x] 04-03: Add and validate optional plugin packaging assets

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Migration Contract | 3/3 | Complete   | 2026-04-01 |
| 2. Codex-Native Surfaces | 4/4 | Complete | 2026-04-01 |
| 3. Workflow Parity Verification | 4/4 | Complete | 2026-04-01 |
| 4. Packaging and Docs Polish | 3/3 | Complete | 2026-04-01 |
