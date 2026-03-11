#!/bin/zsh
# Orchestra auto-attach for Ghostty
# Reattaches to existing devenv session or starts a new one
#
# Usage: Set in Ghostty config:
#   initial-command = ~/.local/bin/orchestra-attach

# Source login profile for PATH (homebrew, fvm, etc.)
[[ -f ~/.zprofile ]] && source ~/.zprofile
[[ -f ~/.zshrc ]] && source ~/.zshrc

ORCH_SESSION="${ORCHESTRA_SESSION:-devenv}"

# Try to reattach to existing session
if tmux has-session -t "$ORCH_SESSION" 2>/dev/null; then
  exec tmux attach -t "$ORCH_SESSION"
fi

# No session — start orchestra from scratch
echo "Starting orchestra session..."
exec ~/.local/bin/dev orchestra
