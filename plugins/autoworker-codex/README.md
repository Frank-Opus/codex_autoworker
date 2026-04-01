# Autoworker Codex Plugin Snapshot

This directory is the optional packaged Codex plugin snapshot for Autoworker.

Source of truth:
- Canonical runtime skills live in `../../.agents/skills/`
- This packaged `skills/` directory is refreshed from the canonical tree via `../../scripts/sync-plugin-package.sh`

Validation:

```bash
../../scripts/verify-plugin-package.sh
```
