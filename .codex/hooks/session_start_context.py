#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts"))

from autoworker_state import build_state, persist_state  # noqa: E402


def repo_root_from(payload: dict) -> Path:
    cwd = payload.get("cwd") or "."
    try:
        resolved = subprocess.check_output(
            ["git", "-C", cwd, "rev-parse", "--show-toplevel"],
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
        if resolved:
            return Path(resolved)
    except Exception:
        pass
    return Path(cwd).resolve()


def active_subtasks(root: Path) -> list[str]:
    files = []
    for path in sorted(root.glob("subtask_*.md")):
        if path.name == "subtask_template.md":
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        if (
            "status: paused" in text
            or "status: completed" in text
            or "Gate result: PASS" in text
        ):
            continue
        files.append(path.name)
    return files


def main() -> int:
    payload = json.load(sys.stdin)
    root = repo_root_from(payload)
    state = build_state(root)
    persist_state(state)
    subtasks = active_subtasks(root)

    if subtasks:
        lines = [
            f"Autoworker state exists on disk at {root}.",
            f"Active subtask(s): {', '.join(subtasks)}.",
            f"Recommended next command: {state['next_command']}.",
            "If the user says continue or provides no newer task, resume with $dispatch.",
            "If the user gives a newer task, create a new subtask with $subtask-init and pause the old one.",
            "Treat disk state as authoritative; do not reconstruct missing decisions from memory.",
            f"Latest workflow snapshot: {state['state_path']}.",
        ]
    elif state["task_plan_exists"]:
        lines = [
            f"Autoworker repo loaded from {root}.",
            "A task_plan.md already exists but no active subtask is running.",
            f"Recommended next command: {state['next_command']}.",
            f"Latest workflow snapshot: {state['state_path']}.",
        ]
    else:
        lines = [
            f"Autoworker repo loaded from {root}.",
            "For non-trivial work, start with $autoworker or $deep-plan.",
            "Prefer file-backed state over chat memory when resuming work.",
            f"Latest workflow snapshot: {state['state_path']}.",
        ]

    response = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": "\n".join(lines),
        }
    }
    json.dump(response, sys.stdout)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
