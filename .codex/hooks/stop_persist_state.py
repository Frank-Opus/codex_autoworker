#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path


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


def active_subtasks(root: Path) -> list[Path]:
    paths = []
    for path in sorted(root.glob("subtask_*.md")):
        if path.name == "subtask_template.md":
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        if "status: paused" in text or "status: completed" in text:
            continue
        paths.append(path)
    return paths


def main() -> int:
    payload = json.load(sys.stdin)
    root = repo_root_from(payload)
    subtasks = active_subtasks(root)

    message = None
    if subtasks:
        gate_pass = any("Gate result: PASS" in p.read_text(encoding="utf-8", errors="ignore") for p in subtasks)
        if not gate_pass:
            names = ", ".join(path.name for path in subtasks)
            message = (
                f"Autoworker active subtask detected ({names}). Persist any new plan decisions, "
                "test evidence, and findings to disk before ending the turn."
            )

    response = {"continue": True}
    if message:
        response["systemMessage"] = message

    json.dump(response, sys.stdout)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
