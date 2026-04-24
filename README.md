# Dev Orchestra

A tmux-based multi-agent AI orchestrator that manages Claude Code and Qwen Code workers from a single terminal. Orchestrate complex tasks across projects with token-efficient sleep patterns, role-separated dual mode (Claude plans / Qwen codes), and persistent project state.

**Key principles:**
- `sleep N` = zero tokens consumed while workers execute
- Claude thinks and reviews. Qwen writes code and runs commands.
- Project state persists across session crashes and terminal restarts
- Up to 5 simultaneous AI sessions across any number of projects

---

## Architecture

```
tmux session: devenv
├── Window 0  → Orchestrator (you issue commands here)
├── Window 1  → Project worker (claude / qwen / dual)
├── Window 2  → Project worker
└── ...
```

### Worker Types

| Type | Composition | Use Case |
|------|-------------|----------|
| `claude` | Single pane, Claude Code | Complex reasoning, analysis, reviews |
| `qwen` | Single pane, Qwen Code | Fast implementation, scripting, quick fixes |
| `dual` | Two panes: Claude← (left) + Qwen→ (right) | Plan → implement → review loops |

Navigate windows with `Ctrl+A <number>` or `Ctrl+A w`.

---

## Installation

### Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| zsh | 5.0+ | Built-in on macOS |
| tmux | 3.0+ | `brew install tmux` |
| Node.js | 18+ | `nvm install 20` or `brew install node` |
| Claude Code | 2.0+ | `npm i -g @anthropic-ai/claude-code` |
| Qwen Code | 0.13+ | `npm i -g @qwen-ai/qwen-code` *(optional for dual mode)* |
| GitHub CLI | 2.0+ | `brew install gh` *(optional, for `dev analyze`)* |

### Quick install (recommended)

```bash
# 1. Install dependencies
brew install tmux gh
npm i -g @anthropic-ai/claude-code
claude login

# 2. Clone and run installer
git clone https://github.com/alperduzgun/claude-orchestra.git ~/.config/orchestra
cd ~/.config/orchestra
./install.sh

# 3. Add to PATH (if installer printed the note)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 4. Verify
dev help
```

`install.sh` symlinks `dev` into `~/.local/bin`, creates `~/.config/orchestra/projects.conf`, and checks prerequisites.

### Manual setup

```bash
# If you prefer not to run install.sh
git clone https://github.com/alperduzgun/claude-orchestra.git ~/.config/orchestra
mkdir -p ~/.local/bin
ln -s ~/.config/orchestra/dev ~/.local/bin/dev

# Optional: dual-mode needs Qwen Code
npm i -g @qwen-ai/qwen-code
```

### Configure Projects

```bash
# Add projects to the registry
dev add myapp /Users/yourname/Development/myapp
dev add backend /Users/yourname/Development/backend

# Or edit directly
nano ~/.config/orchestra/projects.conf
# Format: alias=/path/to/project
```

---

## Quick Start

```bash
# Check all sessions
dev status

# Start a Claude worker
dev start myapp

# Send a task, wait, check output
dev send myapp "Fix the auth bug in src/auth.ts — error: 'user is undefined'"
sleep 30
dev peek myapp

# Start dual mode (Claude plans, Qwen codes)
dev start backend --dual
```

---

## Commands Reference

### Worker Management

| Command | Flags | Description |
|---------|-------|-------------|
| `dev start <alias>` | | Start Claude worker |
| | `--qwen` | Start Qwen worker |
| | `--dual` | Start dual worker (Claude← + Qwen→) |
| `dev kill <alias>` | | Kill a project window |
| `dev recover <alias>` | | Recover crashed session |
| | `--all` | Recover all crashed sessions |
| `dev list` | | Show all configured projects |
| `dev status` | | Show active windows and AI status |

### Messaging

| Command | Flags | Description |
|---------|-------|-------------|
| `dev send <alias> "msg"` | | Send to Claude (default) |
| | `--qwen` | Send to Qwen pane (dual mode) |
| `dev broadcast "msg"` | | Send to all active AI workers |
| `dev ask <alias> "q"` | | Send question, wait for response, show it |

### Monitoring

| Command | Flags | Description |
|---------|-------|-------------|
| `dev peek <alias>` | | Read last 50 lines of output |
| | `--qwen` | Read Qwen pane (dual mode) |
| | `<N>` | Read last N lines |
| `dev done <alias>` | | Check if worker is idle (no context injection) |
| `dev wait <alias>` | | Block until worker finishes; send desktop notification |
| `dev watch <alias>` | | Live tail of worker log |

### Relay (Dual Mode)

| Command | Flags | Description |
|---------|-------|-------------|
| `dev relay <alias>` | `--to-qwen` | Pipe Claude's output to Qwen |
| | `--to-claude` | Pipe Qwen's output to Claude |
| | `--swap` | Both directions simultaneously |

### Project State & Analysis

| Command | Description |
|---------|-------------|
| `dev state show [alias\|--all]` | Show last action, next todo, blockers, history |
| `dev state log <alias> "action"` | Log what was done; persists across restarts |
| `dev state set <alias> <key> <val>` | Set state field (`next_todo`, `blockers`, etc.) |
| `dev state clear <alias>` | Reset all state for a project |
| `dev analyze <alias>` | Live health: git status, open issues, PRs, codebase type |
| `dev analyze --all` | Summary table for all projects |

### Resource Management

| Command | Flags | Description |
|---------|-------|-------------|
| `dev health` | | CPU load, memory free, session count |
| `dev cleanup` | | List idle workers (does NOT kill) |
| | `--confirm` | Kill all idle workers (only after user approval) |
| `dev history [alias] [n]` | | Show recent task history |

---

## Dual Mode

### Core Principle

> **Claude thinks, Qwen executes. Claude never writes code. Qwen never decides architecture.**

| Claude← (Planner / Reviewer) | Qwen→ (Executor) |
|------------------------------|-----------------|
| Analyze the problem | Write the code |
| Design the solution | Run commands (tests, builds, lints) |
| Produce step-by-step plans | Apply the plan file by file |
| Review Qwen's output; spot bugs | Fix issues Claude flags |
| Approve or reject | git add, commit, push |

### Standard Dual Loop

```bash
# 1. Qwen scouts
dev send <alias> --qwen "git status && flutter analyze 2>&1 | tail -10"
sleep 15 && dev peek <alias> --qwen

# 2. Claude plans (does NOT write code)
dev relay <alias> --to-claude
dev send <alias> "Based on Qwen's output, produce a step-by-step implementation plan.
List every file to change and exactly what to do. Do NOT implement — plan only."
sleep 30 && dev peek <alias>

# 3. Qwen implements
dev relay <alias> --to-qwen
dev send <alias> --qwen "Follow the plan above exactly. Implement all changes, run
tests, fix any errors. Report when done."
sleep 60                     # ← zero tokens while Qwen codes
dev peek <alias> --qwen

# 4. Claude reviews
dev relay <alias> --to-claude
dev send <alias> "Review what Qwen implemented. List any issues — do NOT fix them."
sleep 20 && dev peek <alias>

# 5. If issues → relay to Qwen → Qwen fixes → back to step 3
#    If approved → Qwen commits → done
```

### Automated Loop

```bash
dev start myapp --dual
dev send myapp "Plan: add rate limiting to POST /api/users — 10 req/min per IP"
sleep 30 && dev peek myapp          # Confirm plan is ready
dev loop myapp 5                    # Auto plan→implement→review × 5 iterations
dev loop myapp 5 --test-cmd "npm test"  # With test gate: tests must pass before review
```

---

## Spec-Driven Development

Define acceptance criteria before coding. Workers implement exactly what the spec says — nothing more.

### Workflow

```bash
# 1. Create spec
dev spec create myapp rate-limit

# 2. Edit it
nano ~/Development/myapp/.orchestra/specs/rate-limit.md

# 3. Inject into Claude as context
dev spec inject myapp rate-limit

# 4. Run the loop — Claude knows the spec, Qwen implements to it
dev loop myapp 5 --test-cmd "npm test"

# 5. Verify implementation against spec
dev spec check myapp rate-limit
dev peek myapp   # Claude outputs SPEC_COMPLETE or SPEC_INCOMPLETE
```

### Spec Format

```markdown
## Feature: rate-limit
## Acceptance Criteria:
- [ ] POST /api/login rate-limited to 10 req/min per IP
- [ ] Returns 429 with Retry-After header when limit exceeded
- [ ] Uses Redis as the backing store
- [ ] Gracefully degrades to allow-all if Redis is unreachable
## Out of Scope:
- Per-user rate limits (only per-IP)
## Constraints / Notes:
- Must not add latency > 5ms on the happy path
```

### Spec Commands

| Command | Description |
|---------|-------------|
| `dev spec create <alias> <feature>` | Create a blank spec file in project |
| `dev spec show <alias> <feature>` | Print the spec |
| `dev spec list <alias>` | List all specs for a project |
| `dev spec inject <alias> <feature>` | Send spec to Claude as context |
| `dev spec check <alias> <feature>` | Ask Claude to verify implementation vs spec |

Specs live at `<project-dir>/.orchestra/specs/<feature>.md`.

---

## Token Efficiency

### The Sleep Pattern

```bash
dev send <alias> --qwen "implement feature X"   # Qwen starts
sleep 120                                        # ← zero tokens
dev peek <alias> --qwen                         # read once
```

`sleep N` consumes zero tokens. The orchestrator context stays clean. Each `dev peek` injects ~50 lines (~5KB) into context — use it deliberately.

### `dev done` vs `dev peek`

| Command | Context Impact | Use When |
|---------|---------------|----------|
| `dev peek <alias>` | ~5KB injected | You need to read output |
| `dev done <alias>` | Zero | You only need to know if worker is finished |
| `dev wait <alias>` | Zero (notified) | Heavy tasks; you'll work on something else |

**Pattern:** `sleep 120 && dev done <alias>` — zero context injection during execution.

---

## Task Decomposition

For high-level goals, the orchestrator decomposes before executing:

1. User: `"Get all projects release-ready"`
2. Orchestrator analyzes each project (`dev analyze --all`)
3. Proposes Pareto-ordered plan (highest impact, lowest effort first)
4. **User approves**
5. Orchestrator dispatches tasks to workers, monitors, reports milestones

**Rules:**
- Always present the plan before executing — never fully autonomous
- Pareto order: impact ÷ effort, highest first
- Cross-project deps: finish dependencies first
- Report after every sub-task completes

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ORCHESTRA_SESSION` | `devenv` | tmux session name |
| `ORCHESTRA_CONFIG_DIR` | `~/.config/orchestra` | Config and state directory |
| `ORCHESTRA_DIR` | `~/.config/orchestra` | Orchestrator CLAUDE.md location |
| `CLAUDE_BIN` | `$(which claude)` | Path to Claude Code binary |
| `QWEN_BIN` | `$(which qwen)` | Path to Qwen Code binary |
| `MAX_CLAUDE_SESSIONS` | `5` | Max concurrent AI sessions (enforced) |

### File Layout

```
~/.config/orchestra/
├── projects.conf          # Project registry (alias=path)
├── CLAUDE.md              # Orchestrator system prompt
├── states/                # Per-project state files
│   └── myapp.state
└── worker_types/          # Per-window worker type (claude/qwen)
    └── myapp

~/.local/share/orchestra/
├── history.log            # Task history
└── logs/                  # Worker session logs (auto-rotated >100MB)

~/.local/bin/
└── dev                    # The orchestrator script
```

---

## Worker Model

**Claude workers must always use Sonnet.** Set on first use:

```bash
dev send <alias> "/model claude-sonnet-4-6"
```

Opus is reserved for orchestrator-level reasoning. Sonnet is faster and sufficient for all implementation tasks.

---

## Limits & Rules

- **Max 5 AI sessions.** Dual mode counts as 2.
- **`dev send` only works on AI windows.** Shell-only windows error out.
- **Include full context in every worker message.** Workers have zero knowledge of the orchestrator conversation. Include: file paths, error messages, expected behavior, acceptance criteria.
- **Never kill workers without asking the user.** Use `dev cleanup` to list idle; kill only after explicit approval.
- **`dev broadcast` targets all AI windows.** Shell-only windows are skipped.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `tmux not found` | `brew install tmux` |
| `Claude binary not found` | `npm i -g @anthropic-ai/claude-code && claude login` |
| `Qwen binary not found` | `npm i -g @qwen-ai/qwen-code` |
| `gh: command not found` | `brew install gh && gh auth login` |
| Worker not responding | `dev done <alias>` to check; `Ctrl+A <N>` to inspect manually |
| Output cut off | `dev peek <alias> 200` |
| Lost context after restart | `dev state show --all` then `dev history` |
| System slow / high CPU | `dev health` → `dev cleanup` → ask user before killing |

---

## System Requirements (Tested)

- macOS (primary target; Linux should work, Windows WSL untested)
- zsh 5.0+
- tmux 3.0+ (tested: 3.6a)
- Node.js 18+ (tested: v20.20.1)
- Claude Code 2.0+ (tested: 2.1.81)
- Qwen Code 0.13+ (tested: 0.13.0) — optional
- GitHub CLI 2.0+ (tested: 2.88.0) — optional
