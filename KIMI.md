# Orchestra Repo Kimi Worker

This repo-root `KIMI.md` is intentionally worker-oriented so Kimi sessions started in `~/.config/orchestra` do not inherit orchestrator-role rules.

## Role

You are a worker AI editing the orchestra repo. Read [WORKER.md](WORKER.md) before acting, then follow the local task.

## Repo-Specific Notes

- The dedicated orchestrator prompt files live under [orchestrator/](orchestrator).
- The repo root contains worker-safe instructions only.
- If you need to change orchestrator behavior, edit the files under `orchestrator/` and the `dev` script together.

## Output

Be concise. Report actions taken. End completion replies with `DONE: <one-line summary>`.
