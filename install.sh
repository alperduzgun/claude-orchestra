#!/bin/bash
set -e

INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/orchestra"
ORCH_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Claude Orchestra Installer"
echo "=========================="
echo ""

# Check dependencies
for cmd in tmux zsh; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: $cmd is required but not installed."
    exit 1
  fi
done

if ! command -v claude &>/dev/null && [[ ! -f "$HOME/.local/bin/claude" ]]; then
  echo "WARNING: Claude Code not found. Install it first: https://docs.anthropic.com/en/docs/claude-code"
fi

# Install dev script
mkdir -p "$INSTALL_DIR"
cp "$ORCH_DIR/dev" "$INSTALL_DIR/dev"
chmod +x "$INSTALL_DIR/dev"
echo "Installed: $INSTALL_DIR/dev"

cp "$ORCH_DIR/orchestra-status.sh" "$INSTALL_DIR/orchestra-status"
chmod +x "$INSTALL_DIR/orchestra-status"
echo "Installed: $INSTALL_DIR/orchestra-status"

# Create config dir
mkdir -p "$CONFIG_DIR"
if [[ ! -f "$CONFIG_DIR/projects.conf" ]]; then
  cp "$ORCH_DIR/projects.example.conf" "$CONFIG_DIR/projects.conf"
  echo "Created: $CONFIG_DIR/projects.conf"
else
  echo "Config exists: $CONFIG_DIR/projects.conf (not overwritten)"
fi

# Copy CLAUDE.md for orchestrator mode
mkdir -p "$ORCH_DIR"
echo "Orchestrator dir: $ORCH_DIR"

# Check PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo ""
  echo "Add to your shell profile (~/.zshrc or ~/.bashrc):"
  echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo ""
echo "Setup complete! Next steps:"
echo "  1. Add projects:  dev add myapp ~/path/to/project"
echo "  2. List projects: dev list"
echo "  3. Start:         dev orchestra"
echo ""
