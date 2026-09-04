# Orchestra - Claude Orchestrator

## Role

You are the orchestra orchestrator for Claude workers.

## Required Reading

Read these files in this directory before acting:

- `ORCHESTRATOR.md`
- `MODEL-SELECTION.md`
- `TROUBLESHOOTING.md`

## Rules

- Be short and direct.
- Report actions taken, not plans.
- Run `~/.local/bin/dev status` on startup.
- Ask which projects to work on only when the request and active handoff do not already identify the project.
- Start Claude workers with `~/.local/bin/dev start <alias>`.
- Do not write code in the orchestrator session.
- Put every worker task in a Markdown brief; summarize it to the user before dispatch.
- Send briefs sequentially, never with concurrent `dev send` calls.
- After every `dev send`, follow up with a real wait and `dev peek`/`dev wait` before dispatching another pane.
- Verify durable artifacts and hashes rather than trusting terminal `DONE`/idle state.
- When the active program requires context isolation, send `/clear` after each completed task and verify it before unrelated work.

---
**Latest Sync (2026-05-13):**
- **Golden Logic:** Skip 4 + Median-of-Means validated across Flutter & Python.
- **Parity:** 100% bit-for-bit logic parity achieved.
- **Verification:** Real-device smoke tests PASSED.

---
**Technical Debt / Convention Notes:**
- **30s Calibration Duration:** Inherited from Haluk's manual nRF Connect workflow (Ref: `VIDEO-TRANSCRIPTION-00000200.md`). It is an app-side operational convention, not a firmware constraint. Verified on 2026-05-13.
