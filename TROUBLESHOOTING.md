# Orchestra Troubleshooting

Jump to your symptom:

- [`dev: command not found`](#dev-command-not-found)
- [Ghostty tabs don't auto-attach to orchestra](#ghostty-tabs-dont-auto-attach)
- [`tmux: command not found` in Ghostty](#tmux-not-found-in-ghostty)
- [`can't find pane` / `No window for X`](#cant-find-pane--no-window-for-x)
- [`dev start` says "Claude may not be ready"](#claude-may-not-be-ready)
- [Worker not responding to `dev send`](#worker-not-responding)
- [`Cmd+number` keybindings not working](#cmdnumber-not-working)
- [Forge not found / `forge: command not found`](#forge-not-found)
- [Still stuck?](#still-stuck)

---

## `dev: command not found`

**Cause:** `~/.local/bin` is not in your PATH.

**Diagnose:**
```bash
ls ~/.local/bin/dev          # file should exist
echo $PATH | tr ':' '\n' | grep local   # should show ~/.local/bin
```

**Fix:**
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
dev help   # should work now
```

**If the file is missing entirely**, re-run the installer from the repo:
```bash
cd ~/claude-orchestra   # or wherever you cloned it
./install.sh
```

---

## Ghostty tabs don't auto-attach

**Symptom:** Only the first Ghostty tab attaches to orchestra. New tabs (`Cmd+T`) open a plain shell.

**Cause:** The installer wrote `initial-command` instead of `command` to your Ghostty config. These are different keys:
- `initial-command` — runs only in the **first** tab when Ghostty starts
- `command` — runs in **every** new tab and window

**Check:**
```bash
grep -E "^(command|initial-command)" ~/.config/ghostty/config
```

**Fix:**
```bash
sed -i '' 's/^initial-command = /command = /' ~/.config/ghostty/config
```

Restart Ghostty. All new tabs should now auto-attach.

**If `~/.config/ghostty/config` doesn't exist yet:**
```bash
mkdir -p ~/.config/ghostty
echo "command = $HOME/.local/bin/orchestra-attach" >> ~/.config/ghostty/config
```

**If `orchestra-attach` is not executable:**
```bash
chmod +x ~/.local/bin/orchestra-attach
```

---

## `tmux: command not found` in Ghostty

**Symptom:** Ghostty opens but immediately shows `tmux not found` and drops to shell.

**Cause:** Ghostty launches with a minimal environment — Homebrew's `/opt/homebrew/bin` is not in PATH.

The `orchestra-attach` script handles this automatically. If you're still seeing the error, tmux is installed somewhere unusual.

**Find tmux:**
```bash
which tmux   # run this in a normal terminal (not from Ghostty)
```

**Fix — reinstall orchestra-attach with the correct tmux path:**
```bash
cd ~/claude-orchestra
./install.sh   # answer Y to Ghostty auto-restore
```

The installer bakes the current `which tmux` path into the `orchestra-attach` script.

**Or fix manually:**
```bash
# Find tmux path first:
which tmux   # e.g. /opt/homebrew/bin/tmux

# Edit orchestra-attach and set TMUX_BIN:
nano ~/.local/bin/orchestra-attach
# Change: TMUX_BIN="..."  to your actual path
```

---

## `can't find pane` / `No window for X`

**Symptom:** `dev peek myapp` → `No window for myapp`
**Symptom:** `dev send myapp "task"` → `No window for myapp`
**Symptom:** tmux error: `can't find pane: 1`

**Fix A — worker not started:**
```bash
dev start myapp    # start Claude worker first
dev status         # verify it shows [claude]
```

**Fix B — tmux session doesn't exist:**
```bash
tmux ls            # check if 'devenv' session exists
dev                # creates the session if missing
```

**Fix C — worker crashed:**
```bash
dev status         # see which windows exist
dev recover myapp  # restart a crashed worker
```

**Fix D — alias not registered:**
```bash
dev list           # see all configured projects
dev add myapp ~/path/to/project   # add if missing
```

---

## `dev start` says "Claude may not be ready"

**Symptom:**
```
WARNING: Claude may not be ready in myapp (waited 15s)
```

**Cause:** Claude took more than 15s to start (slow machine, first-run update, or auth prompt).

**Fix:** Switch to the window manually and wait for the `❯` prompt:
```bash
# Ctrl+A 1   (or whichever window number was reported)
```

Once the prompt appears, `dev send` works normally.

**If Claude never starts**, check the binary:
```bash
which claude          # should return a path
claude --version      # should print a version
```

If not found: `npm i -g @anthropic-ai/claude-code`

---

## Worker not responding

**Symptom:** `dev send` returns "Sent" but `dev peek` shows no activity.
**Symptom:** `dev done myapp` always returns "working..." indefinitely.

**Diagnose — look at the window directly:**
```bash
# Switch manually: Ctrl+A 1   (the window number from dev status)
# Check the log:
tail -50 ~/.local/share/orchestra/logs/myapp.log
```

**Fix A — worker is waiting for input:**
Switch to the window manually (`Ctrl+A <number>`) and respond to any prompt.

**Fix B — worker crashed silently:**
```bash
dev recover myapp
```

**Fix C — worker is on Opus (slow):**
```bash
dev send myapp "/model claude-sonnet-4-6"
```
Workers should always use Sonnet. Opus is for the orchestrator only.

**Fix D — peek output is garbled:**
```bash
dev peek myapp 200   # try more lines
tail -100 ~/.local/share/orchestra/logs/myapp.log   # raw log
```

---

## Forge not found

**Symptom:**
```
ERROR: Forge binary not found or not executable: /Users/.../.local/bin/forge
```

**Cause:** Forge Code is not installed or not in PATH.

**Install Forge Code:**
```bash
# Option 1: Install via cargo (Rust toolchain required)
cargo install forgecode

# Option 2: Download prebuilt binary from GitHub releases
# https://github.com/tailcallhq/forgecode/releases

# Option 3: Build from source
git clone https://github.com/tailcallhq/forgecode.git
cd forgecode
cargo build --release
cp target/release/forge ~/.local/bin/
```

**Verify:**
```bash
which forge        # should return a path
forge --version    # should print version
```

**If installed in a non-standard location:**
```bash
export FORGE_BIN="/path/to/forge"
```

**Set default provider/model:**
```bash
forge config set session.provider_id minimax
forge config set session.model_id MiniMax-M2.7
```

---

## `Cmd+number` not working

**Requirements:**
1. Ghostty keybindings configured (`super+1=text:\x01\x31` etc.)
2. tmux prefix set to `Ctrl+A` (not the default `Ctrl+B`)

**Check tmux prefix:**
```bash
tmux show-option -g prefix   # should show: prefix C-a
```

**Fix — add to `~/.tmux.conf`:**
```
set -g prefix C-a
unbind C-b
bind C-a send-prefix
```
Reload: `tmux source ~/.tmux.conf`

**Check Ghostty keybindings:**
```bash
grep "super+1" ~/.config/ghostty/config   # should return a line
```

**Fix — re-run installer:**
```bash
cd ~/claude-orchestra
./install.sh   # answer Y to Ghostty Cmd+number keybindings
```

---

## Still stuck?

```bash
dev status    # paste this output
tmux ls       # paste this output
```

Open an issue: https://github.com/alperduzgun/claude-orchestra/issues
