#!/bin/bash
set -e

INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/orchestra"
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
TMUX_CONFIG="$HOME/.tmux.conf"
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

# Verify source files exist
for f in dev orchestra-status.sh orchestra-attach.sh projects.example.conf CLAUDE.md ghostty.example.conf tmux.example.conf; do
  if [[ ! -f "$ORCH_DIR/$f" ]]; then
    echo "ERROR: Missing file: $ORCH_DIR/$f"
    echo "Make sure you're running install.sh from the claude-orchestra repo directory."
    exit 1
  fi
done

# Install scripts
mkdir -p "$INSTALL_DIR"

cp "$ORCH_DIR/dev" "$INSTALL_DIR/dev"
chmod +x "$INSTALL_DIR/dev"
echo "Installed: $INSTALL_DIR/dev"

cp "$ORCH_DIR/orchestra-status.sh" "$INSTALL_DIR/orchestra-status"
chmod +x "$INSTALL_DIR/orchestra-status"
echo "Installed: $INSTALL_DIR/orchestra-status"

cp "$ORCH_DIR/orchestra-attach.sh" "$INSTALL_DIR/orchestra-attach"
chmod +x "$INSTALL_DIR/orchestra-attach"
echo "Installed: $INSTALL_DIR/orchestra-attach"

# Create config dir and copy orchestrator prompt
mkdir -p "$CONFIG_DIR"

cp "$ORCH_DIR/CLAUDE.md" "$CONFIG_DIR/CLAUDE.md"
echo "Installed: $CONFIG_DIR/CLAUDE.md (orchestrator prompt)"

if [[ ! -f "$CONFIG_DIR/projects.conf" ]]; then
  cp "$ORCH_DIR/projects.example.conf" "$CONFIG_DIR/projects.conf"
  echo "Created: $CONFIG_DIR/projects.conf"
else
  echo "Config exists: $CONFIG_DIR/projects.conf (not overwritten)"
fi

# Check PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo ""
  echo "Add to your shell profile (~/.zshrc or ~/.bashrc):"
  echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo ""
echo "Setup complete!"
echo ""

# --- Optional: Ghostty session restore ---
GHOSTTY_CONFIGURED=false
if command -v ghostty &>/dev/null || [[ -d "/Applications/Ghostty.app" ]] || [[ -f "$GHOSTTY_CONFIG" ]]; then
  echo "--- Optional: Ghostty Auto-Restore ---"
  echo ""
  echo "Automatically reattach to your orchestra session when Ghostty opens."
  echo ""
fi

if [[ -f "$GHOSTTY_CONFIG" ]]; then
  if grep -q "initial-command" "$GHOSTTY_CONFIG" 2>/dev/null; then
    echo "Ghostty: initial-command already set (skipping)"
    GHOSTTY_CONFIGURED=true
  else
    read -p "Enable Ghostty auto-restore? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "" >> "$GHOSTTY_CONFIG"
      echo "# Auto-attach to orchestra tmux session on launch" >> "$GHOSTTY_CONFIG"
      echo "initial-command = $INSTALL_DIR/orchestra-attach" >> "$GHOSTTY_CONFIG"
      echo "Ghostty: auto-restore enabled"
      GHOSTTY_CONFIGURED=true
    else
      echo "Ghostty: skipped (you can add manually later)"
    fi
  fi
else
  echo "Ghostty config not found at $GHOSTTY_CONFIG"
  echo "To enable manually, add to your Ghostty config:"
  echo "  initial-command = $INSTALL_DIR/orchestra-attach"
fi

# --- Optional: Ghostty Cmd+number keybindings ---
echo ""
if [[ -f "$GHOSTTY_CONFIG" ]]; then
  if grep -q "super+1=text" "$GHOSTTY_CONFIG" 2>/dev/null; then
    echo "Ghostty: Cmd+number keybindings already set (skipping)"
  else
    echo "--- Optional: Ghostty Cmd+Number Window Switching ---"
    echo ""
    echo "Switch between orchestrator and workers with Cmd+0, Cmd+1, Cmd+2..."
    echo "Requires tmux prefix Ctrl+A (default is Ctrl+B)."
    echo ""
    read -p "Add Cmd+number keybindings to Ghostty? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "" >> "$GHOSTTY_CONFIG"
      cat "$ORCH_DIR/ghostty.example.conf" >> "$GHOSTTY_CONFIG"
      echo "Ghostty: Cmd+number keybindings added"
    else
      echo "Ghostty: keybindings skipped (see ghostty.example.conf)"
    fi
  fi
fi

# --- Optional: tmux configuration (theme + status bar + keybindings) ---
echo ""
echo "--- Optional: tmux Configuration ---"
echo ""
echo "Install orchestra tmux config: Catppuccin Mocha theme, Ctrl+A prefix,"
echo "vim-style navigation, orchestra worker status bar, and sensible defaults."
echo ""
if [[ -f "$TMUX_CONFIG" ]]; then
  if grep -q "orchestra-status" "$TMUX_CONFIG" 2>/dev/null; then
    echo "tmux: orchestra config already present (skipping)"
  else
    echo "WARNING: Existing ~/.tmux.conf will be backed up before changes."
    read -p "Install orchestra tmux config? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      cp "$TMUX_CONFIG" "${TMUX_CONFIG}.backup.$(date +%s)"
      echo "tmux: backed up existing config"
      cp "$ORCH_DIR/tmux.example.conf" "$TMUX_CONFIG"
      echo "tmux: orchestra config installed"
    else
      echo "tmux: skipped (see tmux.example.conf for reference)"
    fi
  fi
else
  read -p "Create ~/.tmux.conf with orchestra config? (y/N) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cp "$ORCH_DIR/tmux.example.conf" "$TMUX_CONFIG"
    echo "tmux: orchestra config created"
  else
    echo "tmux: skipped (see tmux.example.conf for reference)"
  fi
fi

echo ""
echo "Next steps:"
echo "  1. Add projects:  dev add myapp ~/path/to/project"
echo "  2. List projects: dev list"
echo "  3. Start:         dev orchestra"
if [[ "$GHOSTTY_CONFIGURED" == true ]]; then
  echo ""
  echo "Session restore is enabled — just open Ghostty to resume!"
fi
echo ""
