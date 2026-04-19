# Autoworker for Codex CLI

Autoworker is a Codex-first execution workflow for people who want Codex to keep moving for a long time without asking a human to restate the plan every few turns.

It keeps the workflow state on disk, pushes the agent through a strict `plan -> execute -> test -> gate` loop, and refuses to treat optimistic chat summaries as proof that the job is done.

## Why it exists

Long-running agent work usually fails in one of three ways:

- the plan lives only in chat, so a fresh session loses the real intent
- the agent says "done" before real verification happened
- recovery after interruption depends on human memory instead of file-backed state

Autoworker is built to close those gaps.

## What you get

- **Autonomous execution loop**: `$autoworker` -> `$deep-plan` -> `$subtask-init` -> `$dispatch`
- **Durable state**: active `subtask_*.md` survives fresh Codex sessions
- **Machine-readable resume surface**: `python3 scripts/autoworker_state.py --json --write-state`
- **Evidence-first completion**: L1-L4 verification and gate checks must record observed output
- **Hook-assisted recovery**: SessionStart and Stop hooks refresh the on-disk snapshot and remind Codex what to do next
- **Repo-native first**: open the repo in Codex and run it directly; plugin packaging stays optional

## The autonomous model

Autoworker is opinionated:

- humans set direction
- Codex executes
- files carry the workflow state
- verification decides completion

That makes it a better fit for **long-running autonomous work** than for highly conversational, human-in-the-loop coding.

## Quick start

### 1. Open the repository in Codex CLI

The canonical runtime surfaces are:

- `AGENTS.md`
- `.agents/skills/`
- `.codex/hooks.json`
- `.codex/hooks/`
- `scripts/`

### 2. Start a non-trivial task

```text
$autoworker
Build this feature autonomously, verify it with L1-L4 evidence, and only stop on gate-check PASS.
```

### 3. If planning should be explicit first

```text
$deep-plan
Add retry logic to the API client and prove it with build, unit, chain, and end-to-end verification.
```

Then start execution from the written plan:

```text
$subtask-init
Use the existing task_plan.md and begin execution.
```

### 4. Resume after interruption

```text
$dispatch
```

`$dispatch` is the safe resume entry point because it re-reads the on-disk subtask state and routes to the next valid step automatically.

## Durable workflow snapshot

Autoworker now ships with a dedicated state surface for long-running automation:

```bash
python3 scripts/autoworker_state.py --write-state
python3 scripts/autoworker_state.py --json --write-state
```

This produces `.local/autoworker/state.json`, a canonical snapshot of:

- whether `task_plan.md` exists
- which subtasks are active, paused, or completed
- current checkbox progress
- latest workflow activity timestamp
- the recommended next command (`$dispatch`, `$subtask-init`, or `$autoworker`)

The Codex hooks refresh the same snapshot automatically at session start and stop, so the repo can recover more like a harness and less like a chat transcript.

## Validation

Run these from repo root:

```bash
./scripts/verify-hooks.sh
./scripts/verify-codex-workspace.sh
./scripts/verify-autonomy-surface.sh
./scripts/verify-workflow-parity.sh
./scripts/verify-plugin-package.sh
python3 tests/test_autoworker_state.py
```

What they cover:

- `verify-hooks.sh` checks repo-local hook wiring
- `verify-codex-workspace.sh` does a real `codex exec` visibility check
- `verify-autonomy-surface.sh` checks the durable state snapshot plus hook-driven resume guidance
- `verify-workflow-parity.sh` runs the real Codex parity fixture and also validates the new state surface through planning, execution, completion, and recovery
- `verify-plugin-package.sh` checks that the optional packaged plugin matches the canonical `.agents/skills/` tree
- `tests/test_autoworker_state.py` unit-tests the state snapshot logic

## Repo-native usage

Recommended entry points:

- `$autoworker` — full autonomous loop for non-trivial work
- `$deep-plan` — explicit planning discussion
- `$subtask-init` — start execution from an existing `task_plan.md`
- `$dispatch` — resume an active `subtask_*.md`
- `python3 scripts/autoworker_state.py --json --write-state` — inspect or refresh the canonical workflow snapshot

## Optional plugin package

If you want an installable Codex plugin snapshot instead of repo-native usage, this repo also includes:

- `plugins/autoworker-codex/.codex-plugin/plugin.json`
- `plugins/autoworker-codex/skills/`
- `.agents/plugins/marketplace.json`

Refresh the packaged snapshot when canonical skills change:

```bash
./scripts/sync-plugin-package.sh
```

## Repository layout

```text
.
├── AGENTS.md
├── .agents/skills/
├── .codex/hooks.json
├── .codex/hooks/
├── commands/
├── docs/
├── plugins/autoworker-codex/
├── scripts/
└── tests/
```

## Chinese / 中文

### 这是什么

Autoworker 是一个面向 Codex CLI 的自动执行工作流，目标不是“陪聊式写代码”，而是让 Codex 能够：

- 长时间持续推进任务
- 中断后自动恢复
- 把计划、状态、验证结果落到磁盘
- 只有在真实验证通过后才算完成

### 适合谁

如果你的目标是：

- 想让 Codex 长时间自己跑
- 不想每隔几轮就人工重新解释上下文
- 希望恢复依赖文件状态，而不是依赖聊天记忆

那这个仓库就是为这种场景准备的。

### 核心能力

- 严格自动循环：`$autoworker -> $deep-plan -> $subtask-init -> $dispatch`
- 文件化恢复：`subtask_*.md` 和 `task_plan.md` 持久保存工作状态
- 状态快照：`python3 scripts/autoworker_state.py --json --write-state`
- 证据优先：必须跑 L1-L4 验证与 gate-check
- Hook 辅助恢复：会在 session start / stop 时刷新状态快照

### 最常用命令

```text
$autoworker
$deep-plan
$subtask-init
$dispatch
```

查看当前状态：

```bash
python3 scripts/autoworker_state.py --write-state
```

输出机器可读 JSON：

```bash
python3 scripts/autoworker_state.py --json --write-state
```

### 验证命令

```bash
./scripts/verify-hooks.sh
./scripts/verify-codex-workspace.sh
./scripts/verify-autonomy-surface.sh
./scripts/verify-workflow-parity.sh
./scripts/verify-plugin-package.sh
python3 tests/test_autoworker_state.py
```

## License

MIT
