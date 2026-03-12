#!/usr/bin/env zsh
# Orchestra auto-attach for Ghostty
# Reattaches to existing devenv session or starts a new one
#
# Usage: Set in Ghostty config:
#   initial-command = ~/.local/bin/orchestra-attach

# Ensure PATH includes common tool locations
# (Ghostty may run this without loading shell profiles)
for p in /opt/homebrew/bin /usr/local/bin "$HOME/.local/bin"; do
  [[ -d "$p" ]] && [[ ":$PATH:" != *":$p:"* ]] && PATH="$p:$PATH"
done

# Source user profile if available (for custom PATH entries)
[[ -f ~/.zprofile ]] && source ~/.zprofile 2>/dev/null
[[ -f ~/.profile ]] && source ~/.profile 2>/dev/null

ORCH_SESSION="${ORCHESTRA_SESSION:-devenv}"
DEV_BIN="${HOME}/.local/bin/dev"

# Verify dependencies
if ! command -v tmux &>/dev/null; then
  echo "ERROR: tmux not found. Install tmux first."
  echo "Press any key to open a shell instead..."
  read -k 1
  exec zsh -l
fi

if [[ ! -x "$DEV_BIN" ]]; then
  echo "ERROR: dev not found at $DEV_BIN"
  echo "Run install.sh from the claude-orchestra repo first."
  echo "Press any key to open a shell instead..."
  read -k 1
  exec zsh -l
fi

# Try to reattach to existing session
if tmux has-session -t "$ORCH_SESSION" 2>/dev/null; then
  exec tmux attach -t "$ORCH_SESSION"
fi

# No session — create tmux session and drop into shell
# User can start orchestrator manually with `dev` when ready
tmux new-session -d -s "$ORCH_SESSION" -n orchestra -c "${ORCHESTRA_DIR:-$HOME/.config/orchestra}"
exec tmux attach -t "$ORCH_SESSION"
