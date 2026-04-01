---
name: autoworker
description: |
  Auto-loop execution workflow with quality gates. Use when starting any non-trivial implementation task. Provides automatic task decomposition, code implementation, testing (L1-L4), and iterative quality gates until completion. Invoke with $autoworker.
---

# Autoworker: Auto-Loop Execution Workflow

> **Two paths**: Plan Mode (discussion) → /clear → Execution (implementation).
> /clear is the boundary. Different paths, completely different behaviors.

## Core Principles (Apply Throughout)

**The hard standard for "tested"**: Actually execute commands and observe output. The following do NOT count as tested:
- `grep` confirming content exists — only confirms it was written, not that it works
- `bash -n` syntax check — only confirms no syntax errors, not that logic is correct
- `Read` viewing file content — only confirms text is correct, not that execution results are correct

**Counter-intuitive principle**: The smaller the change, the easier it is to skip verification — but verification cost is equally low, so there's no reason to skip.

**Special note**: Instruction file refactoring (SKILL.md / prompt template structural changes) is **not a "documentation task"** — it is the highest-risk change type (silent failure, affects all subsequent sessions) and must be fully verified.

---

## Path A: Plan Mode (Discussion Phase — With Context)

**Trigger**: Receive a non-trivial task → `start planning discussion` (not typo fixes or single-line additions).

**After entering Plan Mode, immediately invoke `$deep-plan`**.

`$deep-plan` ensures discussion depth through 5 structured phases:

| Phase | What | Depth Gate |
|-------|------|-----------|
| 1. Motivation Exploration | Continuously ask why, challenge "is this really needed" | Motivation expressible in 1-3 clear sentences |
| 2. Assumption Challenge | List implicit assumptions, challenge each one | Each assumption has verification method or flagged risk |
| 3. Solution Derivation | Derive solution from motivation, compare alternatives, 4-question review | User makes explicit choice with reasoning |
| 4. Acceptance Criteria | Discuss quantitative/behavioral metrics separately | Each metric can become an L4 test case |
| 5. Plan Output | Consolidate into plan file (fixed format for subtask-init extraction) | 95% confidence self-check passes |

**Forbidden**: Skipping deep-plan and jumping straight to a solution. Plan depth determines the quality ceiling of the execution chain.

→ After `$deep-plan` completes, call `finish planning discussion`. Then `/clear` to enter execution session.

---

## Path B: Execution Session (After /clear — No Context, Only Plan)

**Trigger**: After /clear or new session, you see the plan produced by Plan Mode (injected via system context).

> **Key insight**: This plan is the product of thorough discussion with the user in the previous session.
> Goals, scope, success criteria, and verification methods **have already been confirmed**.
> **No need to ask confirmation questions. The first action is to invoke `$subtask-init` to create subtask.md from the plan and start the execution chain.**
> **Do not investigate before creating subtask — investigation is part of assumption verification inside `$subtask-init`, not a prerequisite.**
>
> **Verified failure mode**: Codex sees plan → wants to "investigate the current state first" → finishes investigating and starts coding directly → subtask.md never created → no execution chain constraints → no gate-check quality gate.

### Execution Chain (Skill Auto-Chaining + Self-Iteration Loop)

**Core idea**: The execution chain is not linear — it's a **self-iteration loop**. Write code → test → check → find gaps → update plan → write more code → test again... until quality meets the bar, then deliver to user. Each step is enforced by skill chaining, leaving no room to skip steps.

```
Execution chain pseudo-code:

$subtask-init
    Pause old active subtask → Write acceptance criteria + status: active
    → $subtask-plan

$subtask-plan
    Multi-subtask positioning (active) → silent failure analysis → acceptance coverage check
    → $dispatch

while $dispatch (multi-subtask positioning):  # Re-read active subtask each time
    match state:
        has incomplete Phase  → $code → $checkpoint → continue
        has untested layer    → $test → $checkpoint → continue
        all tests complete    → $gate-check (acceptance traceability → PASS/FAIL) → continue
        Gate = FAIL           → $subtask-update → continue
        Gate = PASS           → status: completed → output completion report → break
```

| Skill | Responsibility | Chains To |
|-------|---------------|-----------|
| `$subtask-init` | Persist goals + acceptance criteria + assumptions, pause old active, run assumption verification | → `$subtask-plan` |
| `$subtask-plan` | Silent failure analysis + traceability table + L1-L4 verification plan + coverage check + solution self-check | → `$dispatch` |
| `$dispatch` | Multi-subtask positioning (active), read checkbox state, route (sole routing point) | → dynamic |
| `$code` | Implement one Phase of code | → `$checkpoint` |
| `$test` | Execute one test layer | → `$checkpoint` |
| `$checkpoint` | Record keeping (check off Phase / write test results) | → `$dispatch` |
| `$gate-check` | Acceptance criteria traceability + confidence self-assessment + supplementary verification + self-check. Sets completed on PASS | → `$dispatch` |
| `$subtask-update` | Add/correct subtask items | → `$dispatch` |

**Hard rules**:
- The execution chain uses **automatic skill chaining** — each skill forcibly invokes the next at the end. Manual step-skipping is neither needed nor allowed.
- After each test layer passes, you must invoke `$checkpoint` (invoke the skill, do not manually edit subtask).
- Before `$gate-check` PASS, you cannot claim "done".
- Complete all self-executable verification autonomously before returning to user. Do not pause mid-chain to report.
- **No manual skill substitution**: Do not "fill in the verification plan yourself" instead of $subtask-plan, do not "write test results yourself" instead of $checkpoint, do not "route yourself" instead of $dispatch.
- **No chain interruption for context concerns**: After entering Path B, do not suggest /clear, do not say "context is getting full, suggest breaking up", do not stop the execution chain citing context. The 1M context has automatic compression — context management is the system's job, not yours. Your sole responsibility is to run the execution chain until gate-check PASS. (Note: In interactive discussion, suggesting to split genuinely large tasks is reasonable — this rule only constrains the execution chain.)

### Testing: 4 Progressive Layers

| Layer | What It Verifies | Example |
|-------|-----------------|---------|
| **L1 Build** | Compilation/type check passes | `pnpm build`, `bash -n *.sh`, `python -m py_compile` |
| **L2 Unit** | Individual function/module logic is correct | Specific function call + expected output |
| **L3 Chain** | Multi-module collaboration, correct data flow | Feed downstream with actual upstream output, no hand-written simplified data |
| **L4 End-to-End** | Complete user path, from input to final effect | Simulate actual user operation path, no skipping steps |

**L4 is mandatory**. L2/L3 can be skipped but must state justification.

### Mid-Course Correction Protocol (When User Gives Feedback During Execution)

**Trigger**: User says "change to X", "also need to consider Y", "wrong direction", etc.

**Do NOT immediately Edit/Write**. First confirm:
1. **Restate understanding**: "You mean change A to B, because C?"
2. **Ask scope**: "Just this one place or all similar places?"
3. **Ask reason** (if not obvious): Different reasons may lead to completely different implementations.
4. **After confirmation → update subtask.md** → then modify code.

> High-frequency failure mode: User says "change to Y" during execution → immediately Edit → misunderstanding → rework.
> Root cause: Treating user feedback as explicit instruction rather than the start of a discussion.

---

## Execution Rules

### Minimum Change Principle

Only change what the user asked for. No opportunistic refactoring, adding comments, renaming variables, or reformatting. Every line in the diff must map to a user requirement.

### No Silent Error Swallowing

**try/catch**: catch must have explicit recovery logic and specific error types. For Python: no bare `except Exception:`.

**No masking missing values with defaults**: Do not use `dict.get(key, None)`, `getattr(obj, attr, None)` to avoid errors. Only two legal patterns:
- Key definitely exists → `dict[key]` / `obj.attr` (should raise if missing)
- Unsure if exists → explicit `if key in dict` / `hasattr` check before access (clear intent)

### Debug: 2 Failures → Diagnose, Don't Retry

Same approach fails consecutively twice → stop retrying, enter diagnostic mode.

**"Same approach" test**: If modifications are based on the same unverified assumption, it's the same approach even if the code differs.

**Diagnostic three steps**:
1. **Make assumptions explicit**: "I assume: [behavior], because [evidence]" — if you can't write this, you're guessing blindly, stop first
2. **Minimum observable unit**: Break the failing operation into steps where you can see actual state at each point
3. **Build diagnostic tool**: Extract the failing component into a minimal reproducible standalone test

**Counter-intuitive behavior confirmed by diagnosis → write to findings.md**.

### Instruction File Changes Must Be Tested

After modifying SKILL.md or prompt templates, **you must re-run affected workflows**. Instruction files don't throw errors — only actual execution can verify the effect.

Approach: Delete old output → re-run affected workflow → grep to confirm changes took effect.

**L4 for instruction files**: Simulate a fresh session walking the actual user path. Reading file content and thinking "looks right" ≠ verified.

---

## Anti-Loss Protocol

**/clear wipes all conversation context.** Disk files (subtask, progress, plan) survive, but **discussion conclusions that exist only in context are permanently lost.**

### Hard Rules
1. **NEVER suggest /clear** — unless the user explicitly requests it. If context feels long, trust auto-compression (1M context). Context management is the system's job, not yours.
2. **When user requests /clear** — first check: are there discussion conclusions not yet written to files? (plan direction, scope decisions, assumption analysis, user preferences). If yes → write them to plan file / findings.md / subtask progress log FIRST. If no → allow /clear.
3. **Persist discussion results in real-time** — after each deep-plan Phase completes, write conclusions to the plan file immediately. Don't wait until the end to write everything at once. Important findings → write to findings.md immediately.
4. **"Persisted" = written to file** — "remembering" in context does NOT count. Only Write/Edit to a disk file counts as persisted.

### Verified Failure Mode
Codex feels context is too long → suggests /clear → user does it → new session remembers nothing → previous plan discussion completely wasted. Root cause: discussion conclusions were only in context, never written to files.

### Recovery after /clear
When starting a new session after /clear:
1. Check for subtask_*.md files → if found, call $dispatch to resume
2. No subtask but user gives new task → call $subtask-init
3. Neither → normal conversation
4. **If something feels missing** — ask the user to re-state it. Do NOT guess from vague memory.

---

## File Structure

**Navigation rule**: When exploring directories, check AGENTS.md index first, then Glob/Grep. AGENTS.md is a semantic index with higher information density than a file listing.

**Layered AGENTS.md**: Project-level has structure tree + module index; subdirectory-level has file list + purpose.

**File tracking**:

| File | Purpose |
|------|---------|
| `subtask_*.md` | Per-task work document (created by $subtask-init from plan) |
| `task_plan.md` | Project-level plan (big picture) |
| `progress.md` | Project-level progress tracking |
| `findings.md` | Discoveries and counter-intuitive behaviors |

**Archive structure** (`claude_docs/`):

| Subdirectory | Content |
|-------------|---------|
| `subtask/` | Archived subtasks that passed gate-check |
| `debug_log/` | Debug archives |
| `reference/` | Research notes, architecture analysis, non-subtask documents |

---

## Sub Agent Rules

**Preventing stuck agents**: Prompt must contain three elements (all required):
1. **Search scope**: Limit to specific directories/file types/keywords (never write "find all related")
2. **Termination condition**: What to find before returning (e.g., "definition location is sufficient")
3. **Output format**: What form the result should take

**Progressive search**: Glob/Grep → Explore quick → medium → very thorough. Do not start with very thorough.

**Cross-directory**: Explicitly state project root path and working directory path in the prompt.

**Long output analysis**: Short (< 50 lines) — read directly; long logs — use a sub-agent to analyze and return conclusions.

---

## Reference Documents

Consult these files for detailed examples and methodology when needed:

| File | When to Read |
|------|-------------|
| `references/verification_system.md` | When designing verification plans or assumption checks |
| `references/debug_methodology.md` | When hitting 2 consecutive failures and entering diagnostic mode |
| `references/file_conventions.md` | When setting up project file structure or archiving subtasks |
| `references/proxy_metrics.md` | When designing acceptance metrics or proxy indicators |

---

## Recovery After /clear

**Mandatory first step after /clear or new session (before any investigation, reading code, or writing code):**

**Core principle: The user's current message intent > stale file state on disk.**

```
Mandatory flow after /clear (in order, no skipping):

1. First determine the user's current message intent (highest priority):
   a. User message contains an explicit new execution task (has plan, has specific requirements, "Implement X")
      → $subtask-init (create new subtask.md, start new execution chain)
      → Old subtask files don't affect the new task (they're work documents for different tasks)
   b. User has no new task (empty message, pure question, says "continue", etc.)
      → continue to step 2

2. Glob subtask_*.md
   → Exists and has in-progress task → $dispatch (resume execution chain)
   → Does not exist → normal conversation
```

**Forbidden**: Skipping this flow to jump straight into investigation or coding.

**Verified failure modes**:
1. Codex wants to "investigate current state before creating subtask" → finishes investigating and starts coding directly → subtask never created → no execution chain → no quality gates.
2. Old subtask exists + user gave new task → Codex thinks it should dispatch to old subtask → skips $subtask-init → new task has no subtask.md → no execution chain. Root cause: File state prioritized over user intent.
