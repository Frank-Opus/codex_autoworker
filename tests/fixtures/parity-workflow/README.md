# Workflow Parity Fixture

This fixture provides a tiny Python task for real Codex CLI parity checks.

Starting state:
- `app.py` prints `Hello, world!` by default
- `test_app.py` asserts the current behavior

Parity task:
- change the default greeting to `Hello, Codex!`
- keep explicit-name greetings unchanged
- update tests and complete the Autoworker loop with recorded evidence
