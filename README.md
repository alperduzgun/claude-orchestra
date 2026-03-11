# Claude Orchestra

Manage multiple Claude Code sessions from a single terminal. One orchestrator Claude controls worker Claude sessions across your projects via tmux.

## How it works

```
Ghostty / Terminal
└── tmux session: "devenv"
    ├── Window 0: Orchestra (you talk to this Claude)
    ├── Window 1: project-a (worker Claude)
    ├── Window 2: project-b (worker Claude)
    └── Window 3: project-c (worker Claude)
```

- You tell the orchestrator what to do across projects
- It starts worker sessions and assigns tasks
- Switch to any window with `Ctrl+A <number>` for manual control
- Max 3 concurrent Claude sessions (configurable, RAM-dependent)

## Requirements

- macOS or Linux
- [tmux](https://github.com/tmux/tmux) 3.0+
- [zsh](https://www.zsh.org/)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

## Install

```bash
git clone https://github.com/alperduzgun/claude-orchestra.git
cd claude-orchestra
chmod +x install.sh
./install.sh
```

## Setup

Add your projects:

```bash
dev add myapp ~/Development/my-app
dev add backend ~/projects/api-server
dev add frontend ~/code/web-app
```

Projects are stored in `~/.config/orchestra/projects.conf`.

## Usage

```bash
# Start the orchestrator
dev orchestra

# The orchestrator Claude asks which projects to work on
# You say: "myapp and backend"
# It runs: dev start myapp && dev start backend

# Or manually:
dev start myapp          # Start Claude for a project
dev send myapp "fix X"   # Send a task to a project's Claude
dev broadcast "run tests" # Send to all active Claude sessions
dev status               # See what's running
dev kill myapp           # Stop a project session
dev list                 # All projects and their status
```

### Navigation

| Key | Action |
|-----|--------|
| `Ctrl+A 0` | Switch to orchestrator |
| `Ctrl+A 1` | Switch to first project |
| `Ctrl+A 2` | Switch to second project |
| `Ctrl+A w` | List all windows |

## Configuration

Environment variables (set in your shell profile):

| Variable | Default | Description |
|----------|---------|-------------|
| `ORCHESTRA_SESSION` | `devenv` | tmux session name |
| `ORCHESTRA_DIR` | `~/Development/orchestra` | Orchestrator CLAUDE.md location |
| `ORCHESTRA_CONFIG_DIR` | `~/.config/orchestra` | Config directory |
| `MAX_CLAUDE_SESSIONS` | `3` | Max concurrent Claude sessions |
| `CLAUDE_BIN` | auto-detected | Path to Claude Code binary |

## Commands

| Command | Description |
|---------|-------------|
| `dev orchestra` | Start the orchestrator session |
| `dev start <project>` | Start Claude in a tmux window |
| `dev send <project> "msg"` | Send message to a project's Claude |
| `dev broadcast "msg"` | Send to all active Claude sessions |
| `dev status` | Show active windows and Claude status |
| `dev list` | List all configured projects |
| `dev add <alias> <path>` | Add a project |
| `dev remove <alias>` | Remove a project |
| `dev kill <project>` | Kill a project window |
| `dev cc <project>` | Open Claude directly (no orchestration) |
| `dev <project>` | Open a shell in the project |
| `dev help` | Show help |

## Safety

- `dev send` only delivers to windows running Claude — never to a bare shell
- `dev broadcast` skips non-Claude windows automatically
- Session limit is enforced in the script (not just documentation)
- Claude readiness is verified before sending (polls for process, max 15s)
- Messages >1000 chars use tmux buffer (avoids PTY silent truncation at 1024 bytes)

## License

MIT
