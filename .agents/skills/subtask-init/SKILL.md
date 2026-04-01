---
name: subtask-init
description: |
  Create subtask document (first half): user confirmation, goals, assumptions.
  Auto-runs assumption verification experiments and fills in results.
  Call after Gate 1.1 (user confirmation) is done, before writing any code.
---

# $subtask-init — Create Subtask First Half (Gate 1.3 Step A+B)

After Plan Mode discussion is complete and user has confirmed direction, invoke this skill to create the first half of subtask.md.

Critical completion invariant:
- `$subtask-init` has two inseparable halves: `(A) write the first-half subtask skeleton` and `(B) execute every assumption verification command and backfill the Result column`.
- A run that only completes (A) is a failed/incomplete `$subtask-init` run, even if the file was created successfully.
- User text such as "stop before code changes" means "do not modify implementation files"; it does **not** mean "stop before running assumption verification commands".

## Execution Flow

### 1. Determine Sequence Number

```
Glob `subtask_*.md` (current directory) + Glob `claude_docs/subtask/*.md` (archive)
→ Extract all sequence numbers → take max + 1
```

### 2. Extract Confirmation Record from Conversation Context

Review the conversation and extract:
- **Confirmation method**: ask the user / confirmed in plan discussion / explicit in user instruction
- **Key Q&A**: scope, completion criteria, constraints, preferences
- **Goal**: WHY + WHAT (1-3 sentences)
- **Success criteria**: specific measurable items
- **Acceptance criteria**: Extract quantifiable metrics from plan (metric name + measurement method + expected value/range + tolerance). When no quantitative metrics exist, explicitly write "No quantitative metrics, reason: <fill in>"

### 3. Identify Core Assumptions

Extract assumptions that depend on external systems from plan and conversation. Each assumption needs:
- Assumption description (I assume X because Y)
- Verification experiment (one-line command)

Also include required environment/tooling assumptions when the task depends on them, even if the plan did not spell them out explicitly. Examples:
- If planned commands use `python`/`python3`, include an assumption such as `Python 3 is available`
- If planned commands use `pytest`, include an assumption such as `pytest is installed`
- If planned commands depend on a specific file or executable entry point, include that availability assumption when it could block execution

**Pure internal logic changes** (e.g., refactoring, documentation): Write one line `No external dependencies | — | —`.

### 4. Search for Reference Files

```
Glob/Grep search for related files → confirm paths and line numbers
```

**Do not guess line numbers** — must Read to confirm.

**Source-search hygiene**:
- When a verification command is meant to confirm source-of-truth code or config locations, exclude generated workflow artifacts unless they are explicitly part of the target:
  - `task_plan.md`
  - `subtask_*.md`
  - `*.log`
  - `claude_docs/**`
- Example pattern:

```bash
rg -n --glob '!task_plan.md' --glob '!subtask_*.md' --glob '!*.log' --glob '!claude_docs/**' '<pattern>' .
```

### 5. Extract Design Decisions and Plan

Extract from plan file / conversation:
- Design decisions (decision point + choice + reason)
- Implementation plan (Phase/Step structure)

### 5.5. Pause Old Active Subtask

```
Glob `subtask_*.md` (exclude subtask_template.md) →
  For each file grep `status: active` →
    Edit all found to `status: paused`
```

**Purpose**: Ensure at most 1 active subtask at any time. Creating a new subtask automatically pauses old ones.

### 6. Write Subtask First Half

**Language rule**: subtask.md is an internal work document. Write it in the **user's conversation language** (as configured in their AGENTS.md or inferred from their messages). Do NOT use the task's target language — e.g., if the task is "translate to English", the subtask itself should still be in the user's language.

Reference the table structure in subtask template, Write file:

```
subtask_<sequence>_<name>_<date>.md
```

**First line after title: write `status: active`** (flush left, grep-friendly format).

Include these sections (result columns left empty):
- `## User Confirmation Record`
- `## task_plan Positioning` (extract corresponding Phase from plan file, position in overall plan, impact after completion. Write "No task_plan, skip" when none exists)
- `## Goal + Success Criteria`
- `## Acceptance Criteria` table (extract from plan, or write "No quantitative metrics, reason: <fill in>")
- `## Core Assumptions` table (**result column left empty**)
- `## Design Decisions`
- `## Plan`
- `## Reference Files`
- `## Verification Plan` (left empty, filled by $subtask-plan)
- `## Test Results` (left empty, filled by $checkpoint)
- `## Confidence Assessment` (left empty, filled by $gate-check)
- `## Gate 3 Self-Check` (left empty, filled by $gate-check)
- `## Progress Log`
- `## Findings / Conclusions`

**Heading names matter**: downstream workflow skills read these sections by their literal heading text, so keep the exact capitalization and wording shown above.

**Do not stop after this write.** The initial write is only an intermediate state required so assumption results can be filled from real command output in the next step.
Immediately continue to Step 7 in the same run. The next action after creating the file must be executing the first assumption verification command.
Do not print a completion summary, stop-note, or handoff message between Step 6 and Step 7.

### 7. Run Assumption Verification (Critical Step)

**Line by line**, read the "verification experiment" column of the assumptions table:
1. Execute the command
2. Observe the output
3. **Edit** subtask to fill in actual results
4. Move immediately to the next assumption row until all rows are complete

Required completion rule:
- `subtask-init` is **not complete** until every assumption row has a non-empty `Result` cell.
- After filling results, re-open the subtask and confirm there are no blank assumption-result cells left before producing output or chaining onward.
- If a verification command succeeds, summarize the observed output concisely in the `Result` cell (for example: `Confirmed app.py line 4 returns "Hello, world!"` or `Command printed tests-ok`).
- If you have written the subtask file but have not yet run at least one verification command, you are still mid-step and must continue rather than stopping or summarizing.
- If any `Result` cell is blank when you are about to summarize, you must resume verification instead of ending the run.

**Hard rules**:
- Result column must come from command execution output, **cannot be filled by reasoning**
- "—" (no verification needed) must be because there truly are no external dependencies, not laziness
- Verification failure → stop, report to user, do not continue
- Writing the file without backfilling results is an incomplete run, not a valid stopping point
- The required end state for this step is: `subtask file exists` + `all assumption Result cells filled`

### 8. Output

```
Subtask first half created: subtask_<sequence>_<name>.md
- Assumption verification: <N>/<N> passed
- Acceptance criteria: <N> (or "No quantitative metrics")
- Paused old subtask: <list paused filenames, or "None">
→ Automatically invoking $subtask-plan
```

Before emitting this output, perform one final check that the assumptions table contains no empty `Result` cells.

### 9. Chain: Immediately Invoke $subtask-plan

**After outputting the summary above, immediately invoke `$subtask-plan`. Do not wait for user instructions, do nothing else.**

## Important Notes

- **Cannot Write entire file then Edit results**: Write must leave result column empty; only Edit to fill after verification
- **Assumption verification is a blocking step**: Any verification failure → entire flow pauses
- **Reference files must be confirmed**: Glob/Read to confirm paths and line numbers exist — cannot write "approximately line XX"
- **Chaining is mandatory**: Must invoke $subtask-plan after completion, cannot skip or manually substitute
