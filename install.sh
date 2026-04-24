#!/usr/bin/env bash
# install.sh — Claude Orchestra installer
# Symlinks the dev script into ~/.local/bin and sets up the config directory.
set -e

INSTALL_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/orchestra"
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

echo ""
echo "Installation complete."
echo ""
echo "Next steps:"
echo "  1. Add projects: dev add <alias> <path>"
echo "  2. Start a worker: dev start <alias>"
echo "  3. See all commands: dev help"
