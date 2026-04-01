# Workflow Invariants

These invariants define what the Codex migration must preserve.

## Product Invariants

1. **Evidence over assertion**
   - The workflow cannot treat "looks right" as equivalent to tested behavior.
   - Completion claims must be backed by observed verification.

2. **State machine discipline**
   - The execution model remains an explicit loop, not a loose checklist.
   - Routing, implementation, testing, and gating stay conceptually distinct.

3. **File-backed recovery**
   - Progress must survive session interruption via repository artifacts, not only chat memory.

4. **Minimum-change behavior**
   - The workflow should continue discouraging opportunistic refactors and silent behavior drift.

5. **Rework on gate failure**
   - Missing evidence or confidence gaps must route to remediation rather than soft success.

## Migration Invariants

1. Codex-native docs must be the primary happy path.
2. Every retained Claude-specific concept must either have a Codex translation or a documented deprecation note.
3. Hook behavior is optional support, not the primary carrier of workflow correctness.
4. Repo-local usage must be validated before plugin packaging is considered complete.
