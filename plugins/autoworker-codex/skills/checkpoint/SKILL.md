---
name: checkpoint
description: |
  Record progress to subtask: Phase completion (from $code) or test results (from $test).
  Auto-detects upstream type from conversation context. Ends by calling $dispatch.
---

# $checkpoint — Record Progress (Phase Check-off / Test Results)

Called after every $code or $test completion. Performs different record-keeping based on upstream type, then always calls $dispatch.

## Execution Flow

### 1. Locate Subtask

```
Glob `subtask_*.md` (exclude subtask_template.md) →
  0 found → stop, prompt to create subtask
  1 found → use directly (backward compatible)
  multiple → grep `status:` to filter:
    - Files without status field treated as active (backward compatible)
    - Exactly 1 active → use it
    - 0 active → list all files + status, prompt user to choose
    - >1 active → report anomaly
→ Read → locate "## Plan", "## Verification Plan", and "## Test Results" sections
```

### 2. Determine Upstream Type

Prioritize conversation context; when context is insufficient, infer from file state:

- **Upstream is $code**: Conversation contains Phase implementation content; or file has unchecked Phase with corresponding code files already modified
- **Upstream is $test**: Conversation contains test execution output; or file has all Phases checked but incomplete test layers

### 3a. Upstream is $code → Phase Check-off

1. Extract the just-completed Phase number and Step list from conversation context
2. Edit subtask's "Plan" section: check off all Steps for that Phase `[x]`
3. Append completion record in "Progress Log" section:

```markdown
**Phase X complete**
<brief change description>
```

### 3b. Upstream is $test → Test Results Write

1. Extract test level and per-item results from conversation context
2. Edit subtask's "Test Results" section, format:

```markdown
### L<N>
- `<command>`: <output summary> PASS/FAIL
```

3. Check off passed items `[x]` in the "Verification Plan" section

### 4. Judgment Criteria

**Hard standard for "pass"**:
- Function completes expected task and returns **meaningful results**
- Returning empty array/empty string without error ≠ pass
- "No exception thrown" ≠ pass

### 5. Output Summary

```
Checkpoint recorded:
- Type: Phase completion / Test record
- Content: Phase X checked off / L<N> results written
→ Invoking $dispatch
```

### 6. Chain: Immediately Invoke $dispatch

**After outputting the summary, immediately invoke `$dispatch`. Do not wait for user instructions, do nothing else.**

## Important Notes

- **Do not return to user mid-way**: After recording, go directly to $dispatch — don't report or ask
- **Do not skip verification plan items**: The verification plan is a carefully considered product — don't ad-hoc decide "this one doesn't need testing"
- **Chaining is mandatory**: Must invoke $dispatch after completion, cannot skip or manually substitute
