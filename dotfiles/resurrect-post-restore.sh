#!/bin/bash

# Wait until a tmux pane is running a shell (ready to accept commands)
# Usage: wait_for_shell session:window [timeout_seconds]
wait_for_shell() {
  local target="$1"
  local timeout="${2:-10}"
  local elapsed=0

  while [ "$elapsed" -lt "$timeout" ]; do
    pane_cmd=$(tmux display-message -t "$target" -p '#{pane_current_command}' 2>/dev/null)
    if [[ "$pane_cmd" == "bash" || "$pane_cmd" == "zsh" || "$pane_cmd" == "fish" ]]; then
      return 0
    fi
    sleep 0.2
    elapsed=$((elapsed + 1))
  done
  return 1
}

# auth-api: restart logs in the "logs" window
if wait_for_shell "auth-api:logs"; then
  tmux send-keys -t auth-api:logs 'docker-compose -f ../infrastructure/docker-compose.yml logs -f auth-api ' Enter
fi
