<!-- GSD:project-start source:PROJECT.md -->
## Project

**Autoworker for Codex CLI**

Autoworker for Codex CLI is a Codex-native port of the existing Autoworker workflow repo. It keeps the core value of the current project — a strict auto-loop execution workflow with quality gates — but rebuilds packaging, docs, prompts, hooks, and execution assumptions so the workflow runs correctly inside Codex CLI instead of Claude Code.

The product is for people who want a durable, file-backed coding workflow that forces plan → implement → test → gate → retry discipline in Codex CLI sessions, including fresh-session recovery and collaborative agent execution where Codex supports it.

**Core Value:** A Codex CLI user can invoke Autoworker and trust that the workflow advances only with real execution evidence, never with hand-wavy "done" claims.

### Constraints

- **Platform**: Codex CLI native first — the end state must feel idiomatic in Codex, not like Claude prompts pasted into a different shell
- **Compatibility**: Preserve the existing workflow semantics where possible — users should still recognize Autoworker's plan/dispatch/test/gate loop
- **Risk**: Prompt and hook regressions are high risk — instruction changes need direct workflow verification, not just static review
- **Distribution**: The repo should be usable directly from a Codex workspace and support eventual plugin packaging if warranted
<!-- GSD:project-end -->

<!-- GSD:stack-start source:research/STACK.md -->
## Technology Stack

## Recommended Stack
### Core Technologies
| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Codex CLI skills (`SKILL.md`) | Current Codex docs | Primary workflow authoring format | Official docs position skills as the reusable workflow authoring layer and the most direct way to express task-specific behavior in Codex |
| Repo `AGENTS.md` | Current Codex docs | Persistent repository instructions | Codex reads `AGENTS.md` before work and layers repo instructions by path, making it the right replacement for top-level Claude guidance |
| Repo `.agents/skills/` | Current Codex docs | Repository-scoped skill discovery | Official docs state Codex scans `.agents/skills` from the working directory up to repo root, which matches this repo's need for local, versioned workflow skills |
| Repo `.codex/hooks.json` | Experimental current Codex docs | Lifecycle hooks and deterministic validations | Codex supports repo-local hooks with matcher groups and command handlers, which is the closest native replacement for the current Claude stop/session hooks |
| Optional plugin manifest (`.codex-plugin/plugin.json`) | Current Codex docs | Installable distribution of reusable skills | Plugin packaging is the official distribution unit when the workflow should be installable beyond one repository |
### Supporting Libraries
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| POSIX shell scripts | current system shell | Preserve lightweight state persistence and validation utilities | Use for hook commands, migration helpers, and repo-local automation where portability matters |
| Node.js tooling (`gsd-tools`, validation scripts, small codemods) | Current LTS in dev env | Structured file generation and migration utilities | Use when JSON/Markdown rewrites, manifest generation, or repo introspection become too complex for shell |
| Python 3 scripts | current system Python | Hook handlers or cross-platform repo inspections where shell gets brittle | Use selectively for deterministic parsing or hook logic that benefits from stronger text processing |
### Development Tools
| Tool | Purpose | Notes |
|------|---------|-------|
| `rg` | Fast repo discovery | Best fit for mapping Claude-specific assumptions and finding migration targets |
| `git` | Atomic planning and implementation commits | Required to preserve workflow artifacts and review migration progress cleanly |
| Codex built-ins (`/diff`, `/status`, `/init`, `/experimental`) | Verify instructions, inspect changes, and enable optional features | Helpful for dogfooding the migrated workflow inside Codex itself |
## Installation
# No runtime package install is required for the planning docs themselves.
# The implementation direction is:
# 1. Check in repo-scoped skills under .agents/skills/
# 2. Add AGENTS.md in repo root
# 3. Add .codex/hooks.json if hook behavior is required
# 4. Optionally package as a plugin via .codex-plugin/plugin.json
## Alternatives Considered
| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Repo-scoped `.agents/skills` | Keep `skills/` as the only source tree | Use only as an internal source folder if you add a build step that emits Codex-discoverable skills |
| Repo `AGENTS.md` | Put all guidance inside skills only | Use only for tiny repos; AGENTS is better for always-on repository expectations |
| Repo `.codex/hooks.json` | Hand-written reminder text inside prompts | Use prompt-only reminders when hooks remain too experimental for the team's environment |
| Optional plugin packaging | Repo-only distribution | Stay repo-only until the Codex-native workflow is stable and worth sharing across projects |
## What NOT to Use
| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Claude-only plugin install commands as primary UX | They do not map to Codex's discovery and packaging model | Repo skills, AGENTS.md, and optional Codex plugin packaging |
| Claude frontmatter hooks as if Codex reads them | Codex hook discovery is based on `hooks.json` and config layers, not Claude skill frontmatter | `.codex/hooks.json` plus repo-local scripts |
| A dual-primary instruction surface in the first migration milestone | It increases ambiguity and makes verification harder | Codex-first docs with a clearly bounded migration note for legacy Claude behavior |
## Stack Patterns by Variant
- Use `AGENTS.md` + `.agents/skills/` + optional `.codex/hooks.json`
- Because this is the smallest Codex-native surface and easiest to validate incrementally
- Add `.codex-plugin/plugin.json` and a repo marketplace entry under `.agents/plugins/marketplace.json`
- Because official plugin packaging is the supported distribution path for reusable skills
## Version Compatibility
| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| `AGENTS.md` repo guidance | Repo-scoped skills | Complementary: AGENTS sets persistent rules, skills hold task workflows |
| Repo `.codex/hooks.json` | Repo scripts | Hook commands can invoke shell/python/node scripts rooted at the git repo |
| Plugin manifest | `skills/` directory | Manifest can point at packaged skills for installable distribution |
## Sources
- https://developers.openai.com/codex/skills — verified Codex skill authoring model, discovery paths, and plugin relationship
- https://developers.openai.com/codex/guides/agents-md — verified AGENTS.md layering and precedence in Codex
- https://developers.openai.com/codex/hooks — verified repo hook locations, feature flag, and matcher/handler shape
- https://developers.openai.com/codex/plugins/build — verified plugin manifest path and repo marketplace layout
- https://developers.openai.com/codex/cli/slash-commands — verified relevant built-in Codex CLI commands
- `README.md`, `skills/autoworker/SKILL.md`, `scripts/state-persist.sh`, `scripts/state-recover.sh` — current repo baseline
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd:quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd:debug` for investigation and bug fixing
- `/gsd:execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd:profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
