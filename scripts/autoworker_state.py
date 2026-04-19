#!/usr/bin/env python3
"""Compute and optionally persist Autoworker workflow state."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


STATUS_PATTERN = re.compile(r"^status:\s*(.+?)\s*$", re.MULTILINE)
CHECKED_PATTERN = re.compile(r"^- \[x\] ", re.MULTILINE)
UNCHECKED_PATTERN = re.compile(r"^- \[ \] ", re.MULTILINE)
GATE_PATTERN = re.compile(r"Gate result:\s*(PASS|FAIL)", re.IGNORECASE)


@dataclass
class SubtaskSummary:
    name: str
    status: str
    gate_result: str
    checked_items: int
    unchecked_items: int
    updated_at: str
    path: str

    @property
    def total_items(self) -> int:
        return self.checked_items + self.unchecked_items

    @property
    def completion_ratio(self) -> float:
        if self.total_items == 0:
            return 0.0
        return round(self.checked_items / self.total_items, 4)

    def to_dict(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "status": self.status,
            "gate_result": self.gate_result,
            "checked_items": self.checked_items,
            "unchecked_items": self.unchecked_items,
            "total_items": self.total_items,
            "completion_ratio": self.completion_ratio,
            "updated_at": self.updated_at,
            "path": self.path,
        }


def resolve_repo_root(start: str | Path | None = None) -> Path:
    candidate = Path(start or ".").resolve()
    try:
        root = subprocess.check_output(
            ["git", "-C", str(candidate), "rev-parse", "--show-toplevel"],
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
        if root:
            return Path(root).resolve()
    except Exception:
        pass
    return candidate


def isoformat(timestamp: float) -> str:
    return datetime.fromtimestamp(timestamp, tz=timezone.utc).isoformat()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")


def summarize_subtask(path: Path, root: Path) -> SubtaskSummary:
    text = read_text(path)
    status_match = STATUS_PATTERN.search(text)
    gate_match = GATE_PATTERN.search(text)
    stat = path.stat()
    return SubtaskSummary(
        name=path.name,
        status=(status_match.group(1).strip() if status_match else "unknown"),
        gate_result=(gate_match.group(1).upper() if gate_match else "PENDING"),
        checked_items=len(CHECKED_PATTERN.findall(text)),
        unchecked_items=len(UNCHECKED_PATTERN.findall(text)),
        updated_at=isoformat(stat.st_mtime),
        path=str(path.relative_to(root)),
    )


def next_command(
    task_plan_exists: bool,
    subtasks: list[SubtaskSummary],
    active_subtasks: list[SubtaskSummary],
) -> tuple[str, str]:
    terminal_subtasks = {
        subtask.name
        for subtask in subtasks
        if subtask.status == "completed" or subtask.gate_result == "PASS"
    }
    if active_subtasks:
        names = ", ".join(subtask.name for subtask in active_subtasks)
        return "$dispatch", f"Resume the active subtask loop for {names}."
    if subtasks and len(terminal_subtasks) == len(subtasks):
        return "$autoworker", "No active subtasks remain; the last recorded workflow is complete."
    if task_plan_exists:
        return "$subtask-init", "A written plan exists but no active subtask is running."
    return "$autoworker", "No active Autoworker state is on disk yet."


def build_state(root: str | Path | None = None) -> dict[str, Any]:
    repo_root = resolve_repo_root(root)
    subtask_paths = sorted(
        path
        for path in repo_root.glob("subtask_*.md")
        if path.name != "subtask_template.md"
    )
    subtasks = [summarize_subtask(path, repo_root) for path in subtask_paths]
    active_subtasks = [
        subtask
        for subtask in subtasks
        if subtask.status == "active" and subtask.gate_result != "PASS"
    ]

    task_plan = repo_root / "task_plan.md"
    progress = repo_root / "progress.md"
    findings = repo_root / "findings.md"
    tracked_files = [path for path in [task_plan, progress, findings, *subtask_paths] if path.exists()]
    latest_mtime = max((path.stat().st_mtime for path in tracked_files), default=None)
    command, reason = next_command(task_plan.exists(), subtasks, active_subtasks)

    return {
        "generated_at": datetime.now(tz=timezone.utc).isoformat(),
        "repo_root": str(repo_root),
        "task_plan_exists": task_plan.exists(),
        "progress_exists": progress.exists(),
        "findings_exists": findings.exists(),
        "subtasks": [subtask.to_dict() for subtask in subtasks],
        "active_subtasks": [subtask.name for subtask in active_subtasks],
        "active_subtask_count": len(active_subtasks),
        "latest_worklog_at": isoformat(latest_mtime) if latest_mtime else None,
        "next_command": command,
        "next_command_reason": reason,
        "state_path": str(repo_root / ".local" / "autoworker" / "state.json"),
    }


def persist_state(state: dict[str, Any]) -> Path:
    path = Path(state["state_path"])
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(state, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return path


def render_human(state: dict[str, Any]) -> str:
    lines = [
        "Autoworker Status",
        f"- repo: {state['repo_root']}",
        f"- task plan: {'present' if state['task_plan_exists'] else 'missing'}",
        f"- active subtasks: {state['active_subtask_count']}",
    ]
    if state["latest_worklog_at"]:
        lines.append(f"- latest worklog: {state['latest_worklog_at']}")
    if state["subtasks"]:
        lines.append("- subtasks:")
        for subtask in state["subtasks"]:
            lines.append(
                "  - "
                f"{subtask['name']} | status={subtask['status']} | gate={subtask['gate_result']} | "
                f"progress={subtask['checked_items']}/{subtask['total_items']}"
            )
    lines.extend(
        [
            f"- next command: {state['next_command']}",
            f"- why: {state['next_command_reason']}",
            f"- state snapshot: {state['state_path']}",
        ]
    )
    return "\n".join(lines)


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=".", help="repo root or workspace to inspect")
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    parser.add_argument(
        "--write-state",
        action="store_true",
        help="persist the computed state to .local/autoworker/state.json",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    state = build_state(args.root)
    if args.write_state:
        persist_state(state)

    if args.json:
        json.dump(state, sys.stdout, indent=2, ensure_ascii=False)
        sys.stdout.write("\n")
    else:
        print(render_human(state))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
