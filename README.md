<p align="center">
  <img src="assets/claude-orchestra-orc-conductor-banner.png" alt="Claude Orchestra - AI-powered multi-session orchestrator for Claude Code with tmux" width="100%">
</p>

<p align="center">
  <strong>Manage multiple Claude Code sessions from a single terminal.</strong><br>
  One orchestrator Claude controls worker Claude sessions across your projects via tmux.
</p>

<p align="center">
  <a href="#install">Install</a> &bull;
  <a href="#usage">Usage</a> &bull;
  <a href="#commands">Commands</a> &bull;
  <a href="https://github.com/alperduzgun/claude-orchestra/releases">Releases</a>
</p>

---

## Quick Start (for AI Assistants)

Copy-paste this into Claude Code, ChatGPT, or any AI coding assistant to set up Claude Orchestra automatically:

```
Clone and install Claude Orchestra — a tmux-based multi-session manager for Claude Code.

Steps:
1. git clone https://github.com/alperduzgun/claude-orchestra.git ~/claude-orchestra
2. cd ~/claude-orchestra && chmod +x install.sh && ./install.sh
3. The installer will ask about Ghostty auto-restore and tmux multi-client fix — say yes to both if applicable
4. Add my projects with `dev add <alias> <path>` for each project I want to manage
5. If my tmux prefix is Ctrl+A, append the contents of ghostty.example.conf to my Ghostty config for Cmd+number window switching
6. Run `dev` to start the orchestrator

Read the README at ~/claude-orchestra/README.md for the full command reference.
```

---

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
- Close Ghostty and reopen — session resumes where you left off

### Prompt Amplification

The orchestrator doesn't just forward your messages — it **amplifies** them. You give a brief, high-level instruction; the orchestrator translates it into a detailed, context-rich task for each worker.

```
You:            "check for false positives"

Orchestrator:   "14 fixes were applied. Cross-reference each against source:
                 1. dev:16 — verify ORCHESTRA_DIR controls CLAUDE.md path
                 2. dev:760 — verify case statement has claude|cc
                 3. install.sh:88 — verify interactive Ghostty prompt exists
                 ...
                 Return CORRECT or FALSE POSITIVE for each with explanation."
```

Workers have zero context about your conversation. The orchestrator bridges this gap by injecting file paths, line numbers, error messages, and acceptance criteria into every task — so you can stay high-level while workers get exactly what they need.

## Requirements

- macOS or Linux
- [tmux](https://github.com/tmux/tmux) 3.0+
- [zsh](https://www.zsh.org/)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- [Ghostty](https://ghostty.org/) (recommended, for auto-restore)

## Install

```bash
git clone https://github.com/alperduzgun/claude-orchestra.git
cd claude-orchestra
chmod +x install.sh
./install.sh
```

The installer will:
1. Install `dev`, `orchestra-status`, and `orchestra-attach` to `~/.local/bin/`
2. Copy the orchestrator prompt (`CLAUDE.md`) to `~/.config/orchestra/`
3. Create config at `~/.config/orchestra/projects.conf`
4. **Ask** if you want Ghostty auto-restore (adds `initial-command` to Ghostty config)
5. **Ask** if you want tmux multi-client fix (adds `window-size latest` to tmux.conf)

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
# Start the orchestrator (all equivalent)
dev                      # shortest
dev o                    # short alias
dev orchestra            # full command

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

| Key | Action | Requires |
|-----|--------|----------|
| `Ctrl+A 0` | Switch to orchestrator | tmux (default) |
| `Ctrl+A 1` | Switch to first project | tmux (default) |
| `Ctrl+A w` | List all windows | tmux (default) |
| `Cmd+0` | Switch to orchestrator | Ghostty + keybindings |
| `Cmd+1` | Switch to first project | Ghostty + keybindings |

> **Note:** `Cmd+number` keybindings require the Ghostty config from `ghostty.example.conf` and tmux prefix set to `Ctrl+A`. See the example config for details.

### Monitoring & Automation

```bash
dev peek myapp           # Read worker's recent output
dev watch myapp          # Live tail of worker's log
dev done myapp           # Check if worker is idle or working
dev wait myapp           # Wait for worker to finish (default: 5min timeout)
dev ask myapp "question" # Send question, wait for response (2min timeout)
dev run myapp "task"     # Non-interactive task (claude --print)
dev history              # Show recent task history (default: last 30)
dev recover myapp        # Recover crashed session (--resume)
dev recover --all        # Recover all crashed sessions
```

## Session Restore

When Ghostty auto-restore is enabled (via installer), closing and reopening Ghostty automatically reattaches to your orchestra session. All Claude workers continue running in the background via tmux.

```
Close Ghostty → tmux session persists → Reopen Ghostty → auto-reattach
```

To enable manually:

```bash
# Add to ~/.config/ghostty/config:
initial-command = ~/.local/bin/orchestra-attach

# Add to ~/.tmux.conf (prevents size conflicts with multiple windows):
set -g window-size latest
```

## Configuration

Environment variables (set in your shell profile):

| Variable | Default | Description |
|----------|---------|-------------|
| `ORCHESTRA_SESSION` | `devenv` | tmux session name |
| `ORCHESTRA_DIR` | `~/.config/orchestra` | Where `CLAUDE.md` lives (orchestrator working directory) |
| `ORCHESTRA_CONFIG_DIR` | `~/.config/orchestra` | Where `projects.conf` lives (can differ from `ORCHESTRA_DIR`) |
| `MAX_CLAUDE_SESSIONS` | `3` | Max concurrent Claude sessions |
| `CLAUDE_BIN` | auto-detected | Path to Claude Code binary |

> **Note:** `ORCHESTRA_DIR` and `ORCHESTRA_CONFIG_DIR` default to the same path but serve different purposes. `ORCHESTRA_DIR` controls where the orchestrator Claude runs and reads its system prompt. `ORCHESTRA_CONFIG_DIR` controls where the project registry is stored.

## Commands

| Command | Description |
|---------|-------------|
| `dev` / `dev o` / `dev orch` / `dev orchestra` | Start the orchestrator |
| `dev start <project>` | Start Claude in a tmux window |
| `dev send <project> "msg"` | Send message to a project's Claude |
| `dev peek <project> [lines]` | Read worker's recent output (default: 50 lines) |
| `dev watch <project>` | Live tail of worker's log |
| `dev done <project>` | Check if worker is idle or working |
| `dev wait <project> [sec]` | Wait for worker to finish, then notify (default: 300s) |
| `dev ask <project> "msg"` | Send question, wait for response (timeout: 120s) |
| `dev run <project> "task"` | Non-interactive task (claude --print) |
| `dev broadcast "msg"` | Send to all active Claude sessions |
| `dev history [alias] [n]` | Show recent task history (default: 30 lines) |
| `dev recover <project>` | Recover crashed session (--resume) |
| `dev recover --all` | Recover all crashed sessions |
| `dev status` | Show active windows and Claude status |
| `dev list` / `dev ls` | List all configured projects |
| `dev add <alias> <path>` | Add a project |
| `dev remove <alias>` / `dev rm <alias>` | Remove a project |
| `dev notify <title> <msg>` | Send a desktop notification (macOS + Linux) |
| `dev kill <project>` | Kill a project window |
| `dev cc <project>` / `dev claude <project>` | Open Claude directly (no orchestration) |
| `dev <project>` | Open a shell in the project |
| `dev help` | Show help |

## Safety

- `dev send` only delivers to windows running Claude — never to a bare shell
- `dev broadcast` skips non-Claude windows automatically
- Session limit is enforced in the script (not just documentation)
- Claude readiness is verified before sending (polls for process, max 15s)
- Messages >1000 chars use tmux buffer (avoids PTY silent truncation at 1024 bytes)
- Installer never overwrites existing configs — asks before modifying
- Alias names validated (alphanumeric, hyphens, underscores only)
- `CLAUDE_BIN` quoted in all tmux commands (injection prevention)
- Notifications use safe argv passthrough (no shell interpolation)

## License

MIT
