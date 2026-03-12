#!/usr/bin/env zsh
# Orchestra status for tmux status bar
# Shows active workers with status indicators

ORCH_SESSION="${ORCHESTRA_SESSION:-devenv}"
CLAUDE_PROC_PATTERN="^[0-9]+\.[0-9]+\.[0-9]+$"

if ! tmux has-session -t "$ORCH_SESSION" 2>/dev/null; then
  echo ""
  exit 0
fi

result=""
windows=$(tmux list-windows -t "$ORCH_SESSION" -F "#{window_name}|#{pane_current_command}" 2>/dev/null)
while IFS='|' read -r wname pcmd; do
  [[ "$wname" == "orchestra" ]] && continue
  if [[ "$pcmd" =~ $CLAUDE_PROC_PATTERN ]]; then
    # Check if idle by looking for prompt
    output=$(tmux capture-pane -t "$ORCH_SESSION:$wname" -p -S -5 2>/dev/null | \
      sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '\xc2\xa0' | sed 's/[[:cntrl:]]//g')
    if echo "$output" | grep -qiE '(running\)|lculating|rnsfiguring|hinking|Reding.*files|iting.*files)'; then
      result+="#[fg=#f9e2af]⚡${wname}#[default] "
    else
      result+="#[fg=#a6e3a1]✓${wname}#[default] "
    fi
  fi
done <<< "$windows"

echo "$result"
