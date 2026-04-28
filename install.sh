#!/usr/bin/env bash
# install.sh — Claude Orchestra installer
# Symlinks the dev script into ~/.local/bin and sets up the config directory.
set -e

INSTALL_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/orchestra"
GHOSTTY_CONFIG="${HOME}/.config/ghostty/config"
ORCH_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Claude Orchestra installer"
echo "=========================="
echo ""

# ── Dependency check ─────────────────────────────────────────────
missing=()
for cmd in tmux zsh; do
  if ! command -v "$cmd" &>/dev/null; then
    missing+=("$cmd")
  fi
done
if [[ ${#missing[@]} -gt 0 ]]; then
  echo "ERROR: required tools not found: ${missing[*]}"
  echo "Install with: brew install ${missing[*]}"
  exit 1
fi

if ! command -v claude &>/dev/null; then
  echo "WARN: claude CLI not found. Install: npm i -g @anthropic-ai/claude-code"
fi

if ! command -v qwen &>/dev/null; then
  echo "NOTE: qwen CLI not found (optional for dual/qwen modes)."
fi

# ── Verify repo files ────────────────────────────────────────────
if [[ ! -f "${ORCH_DIR}/dev" ]]; then
  echo "ERROR: ${ORCH_DIR}/dev missing. Run install.sh from the repo root."
  exit 1
fi

# ── Create directories ───────────────────────────────────────────
mkdir -p "${INSTALL_DIR}"
mkdir -p "${CONFIG_DIR}"

# ── Symlink dev ──────────────────────────────────────────────────
if [[ -L "${INSTALL_DIR}/dev" || -f "${INSTALL_DIR}/dev" ]]; then
  rm -f "${INSTALL_DIR}/dev"
fi
ln -s "${ORCH_DIR}/dev" "${INSTALL_DIR}/dev"
echo "Installed: ${INSTALL_DIR}/dev -> ${ORCH_DIR}/dev"

# Store repo path so 'dev update' can find it later
orch_conf="${CONFIG_DIR}/orchestra.conf"
{ grep -v "^ORCHESTRA_REPO=" "$orch_conf" 2>/dev/null || true; echo "ORCHESTRA_REPO=\"${ORCH_DIR}\""; } > "${orch_conf}.tmp" && mv "${orch_conf}.tmp" "$orch_conf"
echo "Saved: repo path -> ${orch_conf}"

# ── Create empty projects.conf if missing ────────────────────────
if [[ ! -f "${CONFIG_DIR}/projects.conf" ]]; then
  cat > "${CONFIG_DIR}/projects.conf" <<EOF
# Claude Orchestra project registry
# Format: alias=/absolute/path/to/project
# Add projects with: dev add <alias> <path>
EOF
  echo "Created: ${CONFIG_DIR}/projects.conf"
fi

# ── PATH check ───────────────────────────────────────────────────
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
  echo ""
  echo "NOTE: ${INSTALL_DIR} is not in your PATH."
  echo "Add to your shell config (~/.zshrc or ~/.bashrc):"
  echo ""
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
fi

# ── Optional: Ghostty auto-restore ───────────────────────────────
_install_orchestra_attach() {
  local tmux_bin
  tmux_bin="$(command -v tmux)"
  cat > "${INSTALL_DIR}/orchestra-attach" <<ATTACH_EOF
#!/usr/bin/env zsh
# Extend PATH so tmux is always found (Ghostty starts with minimal env)
for p in /opt/homebrew/bin /usr/local/bin "\${HOME}/.local/bin"; do
  [[ -d "\$p" ]] && [[ ":\$PATH:" != *":\$p:"* ]] && PATH="\$p:\$PATH"
done
TMUX_BIN="${tmux_bin}"
[[ ! -x "\$TMUX_BIN" ]] && TMUX_BIN="\$(command -v tmux 2>/dev/null)" || true
exec "\$TMUX_BIN" new-session -A -s devenv
ATTACH_EOF
  chmod +x "${INSTALL_DIR}/orchestra-attach"
}

if [[ -f "$GHOSTTY_CONFIG" ]]; then
  if grep -qE "^(initial-command|command) = .*orchestra-attach" "$GHOSTTY_CONFIG" 2>/dev/null; then
    echo "Ghostty: auto-restore already configured (skipping)"
  else
    read -p "Enable Ghostty auto-restore (all tabs auto-attach to orchestra)? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      _install_orchestra_attach
      echo "" >> "$GHOSTTY_CONFIG"
      echo "# Auto-attach to orchestra tmux session on every tab/window open" >> "$GHOSTTY_CONFIG"
      echo "command = ${INSTALL_DIR}/orchestra-attach" >> "$GHOSTTY_CONFIG"
      echo "Ghostty: auto-restore enabled"
    else
      echo "Ghostty: skipped (add manually: command = ${INSTALL_DIR}/orchestra-attach)"
    fi
  fi
elif command -v ghostty &>/dev/null || [[ -d "/Applications/Ghostty.app" ]]; then
  read -p "Enable Ghostty auto-restore (all tabs auto-attach to orchestra)? (y/N) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    _install_orchestra_attach
    mkdir -p "$(dirname "$GHOSTTY_CONFIG")"
    echo "# Auto-attach to orchestra tmux session on every tab/window open" >> "$GHOSTTY_CONFIG"
    echo "command = ${INSTALL_DIR}/orchestra-attach" >> "$GHOSTTY_CONFIG"
    echo "Ghostty: auto-restore enabled (created $GHOSTTY_CONFIG)"
  else
    echo "Ghostty: skipped (add manually: command = ${INSTALL_DIR}/orchestra-attach)"
  fi
fi

echo ""
echo "Installation complete."
echo ""
echo "Next steps:"
echo "  1. Add projects: dev add <alias> <path>"
echo "  2. Start a worker: dev start <alias>"
echo "  3. See all commands: dev help"
