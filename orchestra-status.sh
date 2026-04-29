#!/usr/bin/env zsh
# Orchestra status for tmux status bar
# Shows active workers with idle/busy indicators
# Supports: claude, kimi, codex, qwen, gemini

ORCH_SESSION="${ORCHESTRA_SESSION:-devenv}"

if ! tmux has-session -t "$ORCH_SESSION" 2>/dev/null; then
  echo ""
  exit 0
fi

# AI process patterns (claude shows version like 1.2.3 in pane_current_command)
AI_PATTERN="^([0-9]+\.[0-9]+\.[0-9]+|claude|kimi|codex|qwen|gemini|node)$"

# Busy keywords across Claude/Kimi/Codex "thinking" states
BUSY_PATTERN='(running\)|lculating|rnsfiguring|hinking|cogitating|ondering|esigning|nalyzing|orking|earching|eading.*files|riting.*files|xecuting|ompiling|aked for|esc to interrupt)'

result=""
windows=$(tmux list-windows -t "$ORCH_SESSION" -F "#{window_name}|#{pane_current_command}" 2>/dev/null)

while IFS='|' read -r wname pcmd; do
  [[ -z "$wname" ]] && continue
  [[ "$wname" == "orchestra" ]] && continue
  [[ ! "$pcmd" =~ $AI_PATTERN ]] && continue

  output=$(tmux capture-pane -t "$ORCH_SESSION:$wname" -p -S -8 2>/dev/null | \
    sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '\xc2\xa0' | sed 's/[[:cntrl:]]//g')

  if echo "$output" | grep -qiE "$BUSY_PATTERN"; then
    result+="#[fg=#f9e2af,bold]⚡${wname}#[default] "
  else
    result+="#[fg=#a6e3a1]✓${wname}#[default] "
  fi
done <<< "$windows"

echo "$result"
