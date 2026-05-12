#!/usr/bin/env bash
# install.sh — Claude Orchestra installer
# Symlinks the dev script into ~/.local/bin and sets up the config directory.
set -e

INSTALL_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/orchestra"
GHOSTTY_CONFIG="${HOME}/.config/ghostty/config"
TMUX_CONFIG="${HOME}/.tmux.conf"
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
mkdir -p "${CONFIG_DIR}/orchestrator"

# ── Install worker-safe prompt and shared rule files ─────────────
for f in AGENTS.md WORKER.md CLAUDE.md KIMI.md CODEX.md FORGE.md OPENCODE.md GEMINI.md ORCHESTRATOR.md MODEL-SELECTION.md TROUBLESHOOTING.md; do
  if [[ -f "${ORCH_DIR}/${f}" ]]; then
    cp "${ORCH_DIR}/${f}" "${CONFIG_DIR}/${f}"
    echo "Installed: ${CONFIG_DIR}/${f}"
  fi
done

# ── Install dedicated orchestrator prompt directory ──────────────
for f in AGENTS.md CLAUDE.md KIMI.md CODEX.md FORGE.md OPENCODE.md GEMINI.md ORCHESTRATOR.md MODEL-SELECTION.md TROUBLESHOOTING.md; do
  if [[ -f "${ORCH_DIR}/orchestrator/${f}" ]]; then
    cp "${ORCH_DIR}/orchestrator/${f}" "${CONFIG_DIR}/orchestrator/${f}"
    echo "Installed: ${CONFIG_DIR}/orchestrator/${f}"
  fi
done

# ── Symlink dev ──────────────────────────────────────────────────
if [[ -L "${INSTALL_DIR}/dev" || -f "${INSTALL_DIR}/dev" ]]; then
  rm -f "${INSTALL_DIR}/dev"
fi
ln -s "${ORCH_DIR}/dev" "${INSTALL_DIR}/dev"
echo "Installed: ${INSTALL_DIR}/dev -> ${ORCH_DIR}/dev"

# ── Install orchestra-status helper (worker idle/busy indicators) ─
if [[ -f "${ORCH_DIR}/orchestra-status.sh" ]]; then
  if [[ -L "${INSTALL_DIR}/orchestra-status" || -f "${INSTALL_DIR}/orchestra-status" ]]; then
    rm -f "${INSTALL_DIR}/orchestra-status"
  fi
  ln -s "${ORCH_DIR}/orchestra-status.sh" "${INSTALL_DIR}/orchestra-status"
  chmod +x "${ORCH_DIR}/orchestra-status.sh"
  echo "Installed: ${INSTALL_DIR}/orchestra-status -> ${ORCH_DIR}/orchestra-status.sh"
fi

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

# ── Optional: Ghostty Cmd+0-9 keybindings ──────────────────────
if [[ -f "${ORCH_DIR}/ghostty.example.conf" ]] && (command -v ghostty &>/dev/null || [[ -d "/Applications/Ghostty.app" ]]); then
  if [[ -f "$GHOSTTY_CONFIG" ]] && grep -q "super+zero=text" "$GHOSTTY_CONFIG" 2>/dev/null; then
    echo "Ghostty: Cmd+0-9 keybindings already configured (skipping)"
  else
    read -p "Enable Ghostty Cmd+0-9 keybindings (switch tmux windows)? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p "$(dirname "$GHOSTTY_CONFIG")"
      echo "" >> "$GHOSTTY_CONFIG"
      echo "# Claude Orchestra: Cmd+0-9 → tmux window switching (requires Ctrl+A prefix)" >> "$GHOSTTY_CONFIG"
      grep -E "^keybind" "${ORCH_DIR}/ghostty.example.conf" >> "$GHOSTTY_CONFIG"
      echo "Ghostty: Cmd+0-9 keybindings enabled"
    else
      echo "Ghostty: keybindings skipped (see ghostty.example.conf to add manually)"
    fi
  fi
fi

# ── Optional: tmux config (Ctrl+A prefix, tab-style status, mouse) ─
if [[ -f "${ORCH_DIR}/tmux.example.conf" ]]; then
  if [[ -f "$TMUX_CONFIG" ]] && grep -q "Claude Orchestra" "$TMUX_CONFIG" 2>/dev/null; then
    echo "tmux: orchestra config already present (skipping)"
  else
    read -p "Install orchestra tmux config (Ctrl+A prefix, tab-style status, mouse)? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      if [[ -f "$TMUX_CONFIG" ]]; then
        cp "$TMUX_CONFIG" "${TMUX_CONFIG}.bak.$(date +%s)"
        echo "tmux: backed up existing ~/.tmux.conf"
        echo "" >> "$TMUX_CONFIG"
        echo "# ── Claude Orchestra config (appended by install.sh) ──" >> "$TMUX_CONFIG"
        cat "${ORCH_DIR}/tmux.example.conf" >> "$TMUX_CONFIG"
      else
        cp "${ORCH_DIR}/tmux.example.conf" "$TMUX_CONFIG"
      fi
      tmux source-file "$TMUX_CONFIG" 2>/dev/null && echo "tmux: config installed and reloaded" || echo "tmux: config installed (reload with: tmux source-file ~/.tmux.conf)"
    else
      echo "tmux: skipped (see tmux.example.conf to add manually)"
    fi
  fi
fi

echo ""
echo "Installation complete."
echo ""
echo "Next steps:"
echo "  1. Add projects: dev add <alias> <path>"
echo "  2. Start a worker: dev start <alias>"
echo "  3. See all commands: dev help"
