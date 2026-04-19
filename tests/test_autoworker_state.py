#!/usr/bin/env python3
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def run_state(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["python3", str(ROOT / "scripts" / "autoworker_state.py"), *args],
        check=True,
        text=True,
        capture_output=True,
    )


class AutoworkerStateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmpdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tmpdir.name)
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)

    def tearDown(self) -> None:
        self.tmpdir.cleanup()

    def write(self, relative: str, content: str) -> Path:
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        return path

    def load_state(self, *extra: str) -> dict:
        result = run_state("--root", str(self.root), "--json", *extra)
        return json.loads(result.stdout)

    def test_defaults_to_autoworker_when_repo_has_no_state(self) -> None:
        state = self.load_state()
        self.assertEqual(state["next_command"], "$autoworker")
        self.assertFalse(state["task_plan_exists"])
        self.assertEqual(state["active_subtask_count"], 0)

    def test_prefers_subtask_init_when_only_plan_exists(self) -> None:
        self.write("task_plan.md", "# Acceptance Criteria\n- something\n")
        state = self.load_state()
        self.assertEqual(state["next_command"], "$subtask-init")
        self.assertTrue(state["task_plan_exists"])

    def test_prefers_dispatch_when_active_subtask_exists(self) -> None:
        self.write("task_plan.md", "# plan\n")
        self.write(
            "subtask_demo.md",
            "status: active\n\n- [x] L1 build\n- [ ] L2 unit\n## Verification\nGate result: FAIL\n",
        )
        state = self.load_state()
        self.assertEqual(state["next_command"], "$dispatch")
        self.assertEqual(state["active_subtask_count"], 1)
        self.assertEqual(state["subtasks"][0]["checked_items"], 1)
        self.assertEqual(state["subtasks"][0]["unchecked_items"], 1)
        self.assertEqual(state["subtasks"][0]["gate_result"], "FAIL")

    def test_write_state_persists_snapshot(self) -> None:
        self.write("task_plan.md", "# plan\n")
        run_state("--root", str(self.root), "--write-state")
        snapshot = self.root / ".local" / "autoworker" / "state.json"
        self.assertTrue(snapshot.exists())
        payload = json.loads(snapshot.read_text(encoding="utf-8"))
        self.assertEqual(payload["next_command"], "$subtask-init")

    def test_gate_pass_is_treated_as_terminal_even_if_status_lags(self) -> None:
        self.write("task_plan.md", "# plan\n")
        self.write(
            "subtask_demo.md",
            "status: active\n\n- [x] Step 1\nGate result: PASS\n",
        )
        state = self.load_state()
        self.assertEqual(state["active_subtask_count"], 0)
        self.assertEqual(state["next_command"], "$autoworker")
        self.assertEqual(state["subtasks"][0]["gate_result"], "PASS")


if __name__ == "__main__":
    unittest.main(verbosity=2)
