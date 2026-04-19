## Project

Autoworker for Codex CLI is a Codex-native port of the existing Autoworker workflow repo. Preserve the repo's core value: a strict auto-loop execution workflow with quality gates, evidence-based completion, and file-backed recovery.

Core constraints:
- Codex CLI native first; prefer Codex-native mechanisms over Claude-compatible shims
- Preserve the plan/dispatch/test/gate loop semantics wherever possible
- Treat prompt, hook, and workflow-instruction changes as high-risk and verify them directly
- Keep local-repo usability first; optional plugin packaging comes after repo-native validation

## Technology Stack

Primary platform surfaces:
- `AGENTS.md` for repo-wide guidance
- `.agents/skills/` for Codex-discoverable workflow skills
- `.codex/hooks.json` for optional deterministic hook behavior
- `scripts/` for migration helpers, validators, and recovery logic
- optional `.codex-plugin/plugin.json` for installable packaging once stable

Primary workflow entry points:
- `$autoworker` for the full auto-loop on non-trivial tasks
- `$deep-plan` when planning should happen explicitly before execution
- `$subtask-init` when a written plan already exists and execution should start now
- `$dispatch` when resuming an active `subtask_*.md`
- `python3 scripts/autoworker_state.py --json --write-state` when you need the canonical on-disk workflow snapshot

Useful tools:
- `rg` for fast repo discovery
- `git` for atomic planning and implementation commits
- Codex built-ins like `/diff`, `/status`, `/init`, and `/experimental` for dogfooding and verification

## Conventions

- Keep Codex-facing guidance concise in `AGENTS.md`; put detailed workflows in skills
- Prefer one authoritative Codex-visible skill layout instead of parallel trees that can drift
- Document every Claude-specific behavior as one of: migrated, replaced, or deferred
- When changing workflow prompts, hooks, or skill layout, verify behavior with real Codex runs rather than static inspection only

## Architecture

Layer the repository like this:
1. `AGENTS.md` sets always-on repo expectations and entry points
2. `.agents/skills/` contains runnable Codex workflow skills
3. `.codex/hooks.json` plus `scripts/` handle deterministic reminders, validation, and recovery helpers
4. Optional plugin packaging lives separately so distribution does not distort repo-native dogfooding

Avoid frontmatter-compatibility assumptions. Map each Claude-specific feature to a real Codex mechanism or explicitly remove it.

Repo-native validation commands:
- `./scripts/verify-hooks.sh` checks repo-local hook wiring and nested-directory path safety
- `./scripts/verify-codex-workspace.sh` performs a real `codex exec` visibility check against `AGENTS.md` and `.agents/skills/`
- `./scripts/verify-autonomy-surface.sh` checks the durable state snapshot plus hook-driven resume guidance

## GSD Workflow Enforcement

Before using file-changing tools for substantial work, start through a GSD workflow so planning artifacts stay in sync.

Use these entry points:
- `$gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `$gsd-debug` for investigation and bug fixing
- `$gsd-execute-phase` for planned phase work

Do not make broad repo edits outside a GSD workflow unless the user explicitly asks to bypass it.

## Developer Profile

> Profile not yet configured. Run `$gsd-profile-user` to generate your developer profile.
