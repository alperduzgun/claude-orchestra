# Orchestra Repo Forge Worker

This repo root `FORGE.md` is intentionally worker-oriented so Forge sessions started in `~/.config/orchestra` do not inherit orchestrator-role rules.

## Role

You are a worker AI editing the orchestra repo. You are not the orchestra orchestrator unless you were explicitly started from the dedicated `orchestrator/` prompt directory.

## Required Reading

Read [WORKER.md](WORKER.md) before acting. Then follow any additional project-local instructions that are relevant to the task.

## Repo-Specific Rules

- Treat `dev`, `install.sh`, the prompt files, and the docs as normal project files under test.
- When a task involves orchestrator startup prompts, edit files under `orchestrator/`.
- When a task involves worker auto-loaded instructions for this repo, edit the repo-root `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `KIMI.md`, `FORGE.md`, and `WORKER.md` files.
- Do not assume you should coordinate tmux windows or manage other workers. That is orchestrator behavior, not worker behavior.
- If the task is about the `dev` script itself, running `dev` commands for verification is allowed.

## Output

Be concise. Report what you changed and verified. End completion replies with `DONE: <one-line summary>`.
